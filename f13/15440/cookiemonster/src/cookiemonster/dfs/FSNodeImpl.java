package cookiemonster.dfs;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.ObjectOutputStream;
import java.io.IOException;

import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;


import cookiemonster.dfs.Record;
import cookiemonster.dfs.exceptions.FileNotFoundException;
import cookiemonster.dfs.exceptions.MasterUnreachableException;
import cookiemonster.dfs.exceptions.OutOfSpaceException;

import java.util.HashMap;
import java.util.ArrayList;
import java.util.logging.Logger;

import java.net.Socket;
import java.net.InetSocketAddress;

import cookiemonster.Util;


public class FSNodeImpl implements FSNode, Runnable {

    /* FSNode Static Properties */
	static String USAGE = "1. nodename\n2. rmi host\n3. rmi port";

    FSManagerConfig MCONFIG;
    FSNodeConfig CONFIG;

    private static final Logger LOGGER = Logger.getLogger(FSNodeImpl.class.getName());
    public static Registry registry; // gets initialized in the main

    /* An FSNode runs a File Server to let others download files. Here is the inet socket address */
    InetSocketAddress ftpisa;

    /* This node is identified by the node name. It puts all the records in workingDir. */
    public String nodename;
    File workingDir;

    /* We use RMI heavily. this.fman is a stub to the master, this.stub is the stub for this FSNode. */
    FSManager fman;
    public volatile FSNode stub;


    /* FSNode Running State Management */

    /* A file is given an index, and partitioned (on newlines) into one or more records of size CONFIG.RECORDSIZE */
    /* Record is stored on the FS as file<i>record<j> where i is file index and j is record index */
    int lastIndex;     // an ID used for naming things.
    long currSize;         // total bytes used in the DFS
    HashMap<String, Integer> filenameRecordCnt;     // table of filename -> # of records
    HashMap<String, Integer> filenameIndex;         // table of filename -> file index


    /* Local record cache management (keys of cachemap are in cache) */
    HashMap<Record, File> cacheMap;         // table of RemoteRecord -> corresponding file on disk
    ArrayList<Record> remoteRecordsInUse; // list of RemoteRecords whose files we cannot delete.

    /* Constructor
     * Precondition: FSNodeImpl.registry is bound, security policy is set corrctly
     * Effects:
     *         1. Starts file server on separate thread
     *         2. Looks up FSManager in RMI Registry
     * What you need to do after:
     *         1. Export a UnicastRemoteObject
     *         2. Bind the resulting object to the rmiregistry */
    public FSNodeImpl(String nodename, File workingDir, FSManager fmanstub, FSNodeConfig config) throws MasterUnreachableException {
        this.nodename = nodename;
        this.workingDir = workingDir;
        this.lastIndex = 0;
        this.currSize = 0;
        this.filenameRecordCnt = new HashMap<String, Integer>();
        this.filenameIndex = new HashMap<String, Integer>();
        this.cacheMap = new HashMap<Record, File>();
        this.remoteRecordsInUse = new ArrayList<Record>();
        this.fman = fmanstub;
        this.CONFIG = config;
        try {
            this.MCONFIG = this.fman.getConfig();
        } catch (RemoteException e) {
            throw new MasterUnreachableException(e);
        }

        // Check that workingDir exists, is empty, and read/write-able
        if (!workingDir.exists()) {
            LOGGER.severe("Given working directory does not exist: " + this.workingDir);
            System.exit(1);
        }
        if (!workingDir.isDirectory()) {
            LOGGER.severe("Given working directory is not even a directory: " + this.workingDir);
            System.exit(1);
        }
        if (!workingDir.canRead() || !workingDir.canWrite()) {
            LOGGER.severe("Given working directory is not read/write-able: " + this.workingDir);
            System.exit(1);
        }
        if (workingDir.listFiles().length > 0) {
            LOGGER.severe("Given working directory is not empty: " + this.workingDir);
            System.exit(1);
        }

        // Start FSNode File Server
        FileServer fserv = new FileServer(this);
        Thread t = new Thread(fserv);
        t.start();
        while (fserv.isa == null) {
            try {
                Thread.sleep(200);
                LOGGER.info("Waiting for file server to go up");
            } catch (InterruptedException e) {
                System.out.println("InterruptedException");
                System.exit(1);
            }
        }
        this.ftpisa = fserv.isa;

        stub = null;
    }


    
    public String[] ls() throws RemoteException {
    	HashMap<String, ?> filenameMap = this.fman.ls();
    	String[] filenames = new String[filenameMap.size()];
    	filenameMap.keySet().toArray(filenames);
    	return filenames;
    	
    }

    @Override
    public boolean isAlive() {
        return true;
    }

    @Override
    public void writeFile(File f) throws RemoteException, MasterUnreachableException, IOException, OutOfSpaceException {
    	LOGGER.info("Write attempt to " + f);
        assert f.isFile();
        String name = f.getName();
        // break f into records and write/replicate the records.
        BufferedReader br = new BufferedReader(new FileReader(f));
        Replica[] replicas = this.makeLocalRecordReplicas(name, br);
        this.fman.newFile(name, replicas.length);
        this.fman.registerReplicas(replicas);
    }

    /* This one does not tell the fman about the replicas */
    private Replica[] makeLocalRecordReplicas(String name, BufferedReader br) throws IOException, OutOfSpaceException {
        ArrayList<Record> records = new ArrayList<Record>();

        long currentRecordSize = 0;
        int recordIndex = 0;
        Record currRecord = new Record(name, recordIndex);
        records.add(currRecord);
        BufferedWriter bw = new BufferedWriter(new FileWriter(new File(this.workingDir, this.getRecordFileName(currRecord))));
        String line = br.readLine();
        while(line != null) {
            int numBytesInLine = line.getBytes().length;
            assert numBytesInLine <= MCONFIG.RECORD_SIZE;
            currentRecordSize += numBytesInLine;
            if (currentRecordSize > MCONFIG.RECORD_SIZE) {
                bw.close();

                while (this.isFull()) {
                    boolean success = this.incrementalFree();
                    if (!success) {
                    	this.fman.rebalanceReplicas(this.stub);
                    }
                }

                recordIndex ++;
                currentRecordSize = numBytesInLine;
                currRecord = new Record(name, recordIndex);
                bw = new BufferedWriter(new FileWriter(new File(this.workingDir, this.getRecordFileName(currRecord))));
                records.add(currRecord);
            }
            // write line to currRecord
            bw.write(line + "\n");
            line = br.readLine();
        } while(line != null);
        bw.close();
        br.close();

        Replica[] replicas = new Replica[records.size()];
        for (int i = 0; i < records.size(); i ++) {
            Record r = records.get(i);
            replicas[i] = new Replica(r, this);
        }

        // Bookkeeping
        this.filenameRecordCnt.put(name, records.size());
        return replicas;
    }

    /* When writing an object, you may want to remove the local replica
     * (and afterwards re-replicate in order to create balance) */
    @Override
    public void removeLocalReplica(Record r) throws RemoteException, MasterUnreachableException {
        File f = new File(this.workingDir, this.getRecordFileName(r));
        f.delete();
    }

    public String getRecordFileName(Record r) {
        Integer fileIndex = this.filenameIndex.get(r.name);
        if (fileIndex == null) {
            this.lastIndex ++;
            fileIndex = new Integer(this.lastIndex);
            this.filenameIndex.put(r.name, fileIndex);
        }
        return String.format("file%drecord%d", fileIndex, r.recordIndex);
    }

    public File getRecordFile(Record r) throws OutOfSpaceException, MasterUnreachableException {
        File localfile;
        if (this.filenameRecordCnt.containsKey(r.name)) {
            localfile = new File(this.workingDir, this.getRecordFileName(r));
            if (!localfile.exists()) {
            	System.out.println("lets hope this line of code saves us.");
            	localfile = this.acquireRemoteRecord(r);
            }
            // TODO what if the file doesn't exist? (ie if the specific replica was deleted) acquireRemoteRecord.
            // TODO just because a file exists in the map doesn't mean this exact replica is on the machine...
        } else {
            localfile = this.acquireRemoteRecord(r);
        }
        return localfile;
    }

    /* Given a RemoteRecord handler, make sure the file is in the local cache return the path.
     * The returned tempfile is guaranteed to live until you call releaseRemoteRecord */
    public File acquireRemoteRecord(Record r) throws OutOfSpaceException, MasterUnreachableException {
        File f = this.cacheMap.get(r);
        if (f == null) {
            while (this.isFull()) {
                boolean success = this.incrementalFree();
                if (!success) throw new OutOfSpaceException();
            }

            // 1. locate the file by asking the master (get the fsnode stub)
            FSNode stub = null;
            try {
                stub = this.fman.getNodeOfRecord(r);
            } catch (RemoteException e) {
                throw new MasterUnreachableException(e);
            } catch (FileNotFoundException e) {
                // XXX this is not gonna happen.
                System.exit(1);
            }
            assert stub != null;
            // 2. download the file, store it on the hard drive
            f = this.newCacheFile();

            // Unreliable download
            try {
            InetSocketAddress isa = stub.getftpisa();
            LOGGER.info("attemping to download file from "+ isa);
            this.downloadToFile(isa, r, f); // make a connection and read bytes
            } catch (IOException e) {
                // TODO do something...
            	LOGGER.severe("IO Exception while trying to download remote file");
            	throw new RuntimeException(e);
            }

            // 3. add to the cacheMap that we have this file
            this.cacheMap.put(r, f);
            this.remoteRecordsInUse.add(r);
        }
        return f;
    }

    public File newCacheFile() {
        this.lastIndex ++;
        return new File(this.workingDir, String.format("cache%d", this.lastIndex));
    }
    public boolean isFull() {
        return ((CONFIG.MAXSIZE - this.currSize) < MCONFIG.RECORD_SIZE);
    }

    public void releaseRemoteRecord(Record r) {
        this.remoteRecordsInUse.remove(r);
    }

    public boolean incrementalFree() {
        for (Record r : this.cacheMap.keySet()) {
            boolean inUse = false;
            for (Record r2 : this.remoteRecordsInUse) {
                if (r.equals(r2)) {
                    inUse = true;
                    break;
                }
            }
            if (!inUse) {
                File rfile = this.cacheMap.get(r);
                this.cacheMap.remove(r);
                rfile.delete();
                return true;
            }
        }
        return false;
    }

    public InetSocketAddress getftpisa() throws RemoteException {
        return this.ftpisa;
    }

    private BufferedReader downloadReader(InetSocketAddress isa, Record r) throws IOException {
        Socket sock = new Socket(isa.getAddress(), isa.getPort());
        ObjectOutputStream oos = new ObjectOutputStream(sock.getOutputStream());
        oos.writeObject(r);

        BufferedReader br = new BufferedReader(new InputStreamReader(sock.getInputStream()));
        return br;
    }

    public void downloadToFile(InetSocketAddress isa, Record r, File destFile)
            throws IOException {
        BufferedReader br = this.downloadReader(isa, r);
        FileWriter fos = new FileWriter(destFile);
        BufferedWriter bos = new BufferedWriter(fos);

        int b = br.read();
        while(b != -1) {
            bos.write(b);
            b = br.read();
        }
        bos.close();
        br.close();
    }

    @Override
    public Record[] recordsOfFiles(String[] filenames)
            throws RemoteException, MasterUnreachableException {
        ArrayList<Record> records = new ArrayList<Record>();
        HashMap<String, Integer> fileRecordCnt = this.fman.ls();

        System.out.println(fileRecordCnt);

        //for (String fname : fileRecordCnt.keySet()) {
        for (String fname : filenames) {
        	System.out.println("File " + fname);
            for (int i = 0; i < fileRecordCnt.get(fname); i++) {
                records.add(new Record(fname, i));
            }
        }

        Record[] recordArr = new Record[records.size()];
        return records.toArray(recordArr);
    }

    // TODO check if i should do something with the replicas
    @Override
    public void createReplicaOf(Replica replica)
            throws RemoteException, IOException, OutOfSpaceException,
            MasterUnreachableException {

        InetSocketAddress isa = replica.node.getftpisa();
        BufferedReader br = this.downloadReader(isa, replica.record); // make a connection and read bytes
        Replica[] replicas = this.makeLocalRecordReplicas(replica.record.name, br);
        br.close();
    }

    /* Run:
     *         1. Constructs an FSNodeImpl
     *         2. exposes it to the RMI Registry
     *         3. stays alive */
    public void run() {


        // Create a FSNodeImpl object stub and expose via RMI
        try {
            FSNode stub = (FSNode) UnicastRemoteObject.exportObject(this, 0);
            this.stub = stub;

            // Bind the remote object's stub in the registry
            //FSNodeImpl.registry.rebind("FSNode " + this.nodename, stub);

            System.err.println("FSNode ready");
            this.fman.registerNode(this.nodename, stub);

        } catch (Exception e) {
            System.err.println("FSNode exception: " + e.toString());
            e.printStackTrace();
            System.exit(1);
        }

        // RMI system keeps the process running. The FSNodeImpl is available to accept calls
        // and won't be reclaimed until its binding is removed from the registry
        // and no remote clients hold a remote reference to the FSNodeImpl object.
        // source: http://docs.oracle.com/javase/tutorial/rmi/implementing.html
    }

    public static void main(String[] args) {

        if (args.length != 3) {
            System.out.println(USAGE);
        }
        String nodename = args[0];
        String reghost = args[1];
        int regport = Integer.parseInt(args[2]);

        // Set up this VM to be able to use RMI
        try {
            Util.preRMISetup(FSNodeImpl.class);
        } catch (IOException e1) {
            System.out.println("Error while creating security/policy file:");
            e1.printStackTrace();
            System.exit(1);
        }

        try {
            FSNodeImpl.registry = LocateRegistry.getRegistry(reghost, regport);
        } catch (RemoteException e) {
            System.out.println("Error connecting to RMI Registry. Is it on? Traceback:");
            e.printStackTrace();
        }

        // Connect to the FSManager
        FSManager fmanstub = null;
        FSNodeConfig configObj = null;
        try {
            fmanstub = (FSManager) FSNodeImpl.registry.lookup("FSManager");
            configObj = new FSNodeConfig(fmanstub.getConfig().originalMap);
        } catch (Exception e) {
            System.out.println("Couldn't do a lookup in registry:");
            e.printStackTrace();
            System.exit(1);
        }
        assert fmanstub != null;
        try {
            FSNodeImpl obj = new FSNodeImpl(nodename, new File(configObj.workingDir + nodename), fmanstub, configObj);
            obj.run();
        } catch (MasterUnreachableException e) {
            throw new RuntimeException(); // TODO more elegant solution plz
        }


    }

}
