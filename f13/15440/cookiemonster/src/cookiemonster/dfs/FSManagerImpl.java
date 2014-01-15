package cookiemonster.dfs;

import java.io.IOException;
import java.io.File;
import java.io.BufferedReader;
import java.io.FileReader;
import java.rmi.AccessException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;
import java.util.Date;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

import cookiemonster.ConfigSyntaxError;
import cookiemonster.Util;
import cookiemonster.dfs.exceptions.FileNotFoundException;
import cookiemonster.dfs.exceptions.MasterUnreachableException;
import cookiemonster.dfs.exceptions.OutOfSpaceException;

/*
 * File System Master Server - A way for FSNodes to coordinate.
 * 		-Is a registry for nodes by nodename		
 * 		-Stores locations of file's records.
 * 		-Fixes replication in the case that a node becomes unavailable
 */

public class FSManagerImpl implements FSManager, Runnable {
	
	FSManagerConfig CONFIG;

	private static Logger LOGGER = Logger.getLogger(FSManagerImpl.class.getName());
	
	static String USAGE = "1. path to the config file\n2. rmi host\n3. rmi port";

	private static Registry registry;
	
	public volatile FSManager stub;

	/* Information about connected nodes */
	// Stores nodename -> (FSNode stub, Time last seen)
	private ConcurrentHashMap<String, FSNode> nodeNameMap;
	private ConcurrentHashMap<String, Date> nodeNameTimeMap;
	ConcurrentHashMap<String, Integer> fileRecordCnt;
	private ConcurrentHashMap<Record, ArrayList<Replica>> recordReplicaMap;
	private ConcurrentHashMap<FSNode, ArrayList<Replica>> nodeReplicaMap;

	
	public FSManagerImpl(FSManagerConfig config) {
	    this.nodeNameMap = new ConcurrentHashMap<String, FSNode>();
	    this.nodeNameTimeMap = new ConcurrentHashMap<String, Date>();
	    this.fileRecordCnt = new ConcurrentHashMap<String, Integer>();
		this.recordReplicaMap = new ConcurrentHashMap<Record, ArrayList<Replica>>();
		this.nodeReplicaMap = new ConcurrentHashMap<FSNode, ArrayList<Replica>>();
		this.CONFIG = config;
	}
	
	@Override
	public Replica[] getReplicasOfRecord(Record r) throws RemoteException {
		ArrayList<Replica> recreps = this.recordReplicaMap.get(r);
		Replica[] recrepsarr = new Replica[recreps.size()];
		return recreps.toArray(recrepsarr);
	}

	/* Info about all files in the filesystem */
	@Override
	public HashMap<String, Integer> ls() throws RemoteException {
		return new HashMap<String, Integer>(this.fileRecordCnt);
	}

    public void handleFailure(FSNode n) {
    	// remove n from the hashmaps etc.
    	// TODO fix replication
    	LOGGER.info("Call to handle failure for node " + n.toString());
    }
   
    public void heartbeatForever() {
    	while(true) {
    		for (FSNode n : this.nodeNameMap.values()) {
    			try {
    				n.isAlive();
    			} catch (RemoteException e) {
    				handleFailure(n);
    			}
    		}
    		try {
				Thread.sleep(this.CONFIG.HEARTBEAT_PERIOD * 1000);
			} catch (InterruptedException e) {
				System.out.println("Shutting down this sleeping thread:");
				e.printStackTrace();
				return;
			}
    	}
    }
   
    // called by a FSNode, which passes it's own stub.
    // also used by an FSNode to refresh it's status as "alive"
	@Override
	public void registerNode(String nodename, FSNode fsnode) {
		try {
			FSManagerImpl.registry.rebind("FSNode " + nodename, fsnode);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		Date timenow = new Date();
		this.nodeNameMap.put(nodename, fsnode);
		this.nodeNameTimeMap.put(nodename, timenow);
    	LOGGER.info("Registered node  " + nodename);
	}

	/* Randomly returns a node where you can find this record. */
	@Override
	public FSNode getNodeOfRecord(Record r) throws RemoteException {
		Replica rr = this.recordReplicaMap.get(r).get(0);
		// TODO what if the above get(r) returns null? 
		return rr.node;
	}

	@Override
	public void registerReplicas(Replica[] replicas) {
		//LOGGER.info("Registering " + replicas.length + " replicas (in)");
		for (Replica r : replicas) {
			//LOGGER.info("Registering " + replicas.length + " replicas (for)");
			ArrayList<Replica> recordReps = this.recordReplicaMap.get(r.record);
			ArrayList<Replica> nodeReps = this.nodeReplicaMap.get(r.node);
			if (recordReps == null) {
				recordReps = new ArrayList<Replica>();
				this.recordReplicaMap.put(r.record, recordReps);
			}
			if (nodeReps == null) {
				nodeReps = new ArrayList<Replica>();
				this.nodeReplicaMap.put(r.node, nodeReps);
			}
			recordReps.add(r);
			nodeReps.add(r);
			try {
				this.fixReplication(r.record);
			} catch (FileNotFoundException e) {
				assert false; // this can't happen since we create the array list above.
			}
		}
		//LOGGER.info("Registering " + replicas.length + " replicas (end)");
	}

	@Override
	public void newFile(String name, Integer recordCnt) {
		this.fileRecordCnt.put(name, recordCnt);
	}

	@Override
	public void newFiles(HashMap<String, Integer> miniFileRecordCnt) {
		this.fileRecordCnt.putAll(miniFileRecordCnt);
	}

	/* Given a record, replicate it across FSNodes until Replication Factor is met.
	 * 1. Get all current replicas and their nodes
	 * 2. Until properly replicated:
	 * 	a. For each node, if no replica there, tell it to create a replica */
	public void fixReplication(Record r) throws FileNotFoundException {
		
		ArrayList<Replica> replicas = this.recordReplicaMap.get(r);
		if (replicas == null) throw new FileNotFoundException();
		
		HashSet<FSNode> nodesOfReplicas = new HashSet<FSNode>();
		for (FSNode n : this.nodeNameMap.values()) nodesOfReplicas.add(n);

		int replicationTasksRemaining = CONFIG.REPLICATION_FACTOR - replicas.size();
		if (replicationTasksRemaining <= 0)
			return;
		//LOGGER.info("Making "+ replicationTasksRemaining + " of " + r);
		for (FSNode n : this.nodeNameMap.values()) {
			replicationTasksRemaining = CONFIG.REPLICATION_FACTOR - replicas.size();
			if (replicationTasksRemaining <= 0)
				return;
			if (!nodesOfReplicas.contains(n)) {
				try {
					n.createReplicaOf(replicas.get(0));
					// The remote FSNode will createReplica and call registerReplicas.
					// registerReplicas will call fixReplication (this) and the 
					return;
				} catch (RemoteException e) {
					// TODO handle failure
					e.printStackTrace();
				} catch (IOException e) {
					// TODO handle failure
					e.printStackTrace();
				} catch (OutOfSpaceException e) {
					// TODO handle failure
					e.printStackTrace();
				} catch (MasterUnreachableException e) {
					// TODO handle failure
					e.printStackTrace();
				}
			}
		}
	}

	@Override
	public FSManagerConfig getConfig() throws RemoteException {
		return this.CONFIG;
	}

	/* A node may request the master to re-balance the replicas in an effort to free space on the node. */
	public void rebalanceReplicas(FSNode node) throws RemoteException, OutOfSpaceException {
		LOGGER.info("Call to rebalance replicas from " + node);
		// if this fails, that means master doesn't know about any of the replicas, which means something is dearly wrong.
		Replica someReplica = this.nodeReplicaMap.get(node).get(0);
		
		Record someRecord = someReplica.record;
		try {
			node.removeLocalReplica(someRecord);
		} catch (MasterUnreachableException e) {
			// TODO handle failure
			e.printStackTrace();
		}
		this.nodeReplicaMap.get(node).remove(0);
		
	}

	public void run() {
		

        // Create a FSManagerImpl object and expose via RMI
        try {
            FSManager stub = (FSManager) UnicastRemoteObject.exportObject(this, 0);
            this.stub = stub;

            System.out.println(System.getProperty("java.rmi.server.codebase"));
            // Bind the remote object's stub in the registry
            FSManagerImpl.registry.rebind("FSManager", stub);

            System.err.println("FSManager ready. Waiting for nodes and starting the heartbeats.");

            this.heartbeatForever();

        } catch (Exception e) {
            System.err.println("FSManager exception: " + e.toString());
            e.printStackTrace();
            System.exit(1);
        }
	}

    public static void main(String[] args) {
    	/* Check args */
    	if (args.length != 3) {
    		System.out.print(USAGE);
    		System.exit(1);
    	}
    	String configpath = args[0];
    	String reghost = args[1];
    	int regport = Integer.parseInt(args[2]);
    	
    	/* Read and parse config */
    	ArrayList<String> lines = new ArrayList<String>();
    	try {
	    	BufferedReader br = new BufferedReader(new FileReader(new File(configpath)));
	    	String l = br.readLine();
	    	while(l != null) {
	    		lines.add(l);
	    	  l = br.readLine();
	    	}
	    	br.close();
    	} catch (IOException e) {
    		throw new RuntimeException("Error reading config file");
    	}
    	String[] lineArr = new String[lines.size()];
    	HashMap<String, String> configHash = null;
    	FSManagerConfig configObj = null;
		try {
			configHash = Util.parseConfig(lines.toArray(lineArr));
			configObj = new FSManagerConfig(configHash);
		} catch (ConfigSyntaxError e) {
			System.out.println("Error parsing config - plz check syntax");
			System.exit(1);
		} assert configHash != null;

		/* Get registry + broadcast */
    	try {
			Util.preRMISetup(FSManagerImpl.class);
			FSManagerImpl.registry = LocateRegistry.getRegistry(reghost, regport);
		} catch (IOException e1) {
			System.out.println("Error while creating security/policy file:");
			e1.printStackTrace();
			System.exit(1);
		}
        FSManagerImpl obj = new FSManagerImpl(configObj);
        obj.run(); // exports object to the registry
    }
}
