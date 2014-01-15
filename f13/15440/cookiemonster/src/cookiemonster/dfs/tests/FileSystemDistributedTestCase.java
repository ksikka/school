package cookiemonster.dfs.tests;

import static org.junit.Assert.*;

import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;

import org.junit.rules.TemporaryFolder;
import org.junit.Rule;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import cookiemonster.Util;
import cookiemonster.dfs.FSManagerConfig;
import cookiemonster.dfs.FSManagerImpl;
import cookiemonster.dfs.FSNodeConfig;
import cookiemonster.dfs.FSNodeImpl;
import cookiemonster.dfs.Record;
import cookiemonster.dfs.RecordReader;

import java.rmi.registry.Registry;
import java.util.ArrayList;
import java.util.HashMap;

import java.io.File;
import java.io.IOException;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class FileSystemDistributedTestCase {

	@Rule
	public TemporaryFolder folder = new TemporaryFolder();
	
	public FSManagerImpl fsman;
	public Thread FSManagerThread;
	
	FSNodeImpl[] fsnodeVector;
	Thread[] FSNodeThreadVector;
	String[] fsnodenames;
	
	/* TESTS REPLICATION: 1 MASTER 5 SLAVE CONFIG WITH REPLICATION = 3 AND RECORD SIZE = 3MB */
	@Before
	public void setUp() throws Exception {
		// Set up this VM to be able to use RMI
        try {
            Util.preRMISetup(FSNodeImpl.class);
        } catch (IOException e1) {
            System.out.println("Error while creating security/policy file:");
            e1.printStackTrace();
            System.exit(1);
        }
        
        try {
        	Registry registry = LocateRegistry.getRegistry();
            FSNodeImpl.registry = registry;
        } catch (RemoteException e) {
        	System.out.println("Error connecting to RMI Registry. Is it on? Traceback:");
        	e.printStackTrace();
        }

        HashMap<String, String> confighash = new HashMap<String, String>();
        confighash.put("replication_factor", "3");
        confighash.put("record_size", "3000000"); // 3 MB records

        FSManagerImpl fmanimpl = new FSManagerImpl(new FSManagerConfig(confighash));  
        Thread t = new Thread(fmanimpl);
        t.start();
        this.FSManagerThread = t;
        this.fsman = fmanimpl;
        while(this.fsman.stub == null) {
        	System.out.println("Waiting for FS Manager to start up");
        	Thread.sleep(100);
        }
        
        String[] names = {"edwin", "lisa", "bart", "maggie", "stewie"};
        this.fsnodenames = names;
        int numNodes = this.fsnodenames.length;
    	this.fsnodeVector = new FSNodeImpl[numNodes];
    	this.FSNodeThreadVector = new Thread[numNodes];       
        
        for (int i = 0; i < numNodes; i ++) {
        	File workingDir = this.folder.newFolder(names[i]);
            FSNodeImpl obj = new FSNodeImpl(names[i], workingDir, fmanimpl.stub, new FSNodeConfig(confighash));
            Thread t2 = new Thread(obj);
            t2.start();
            this.FSNodeThreadVector[i] = t;
            this.fsnodeVector[i] = obj;
        }

        for (FSNodeImpl fsnode : this.fsnodeVector) {
	        while(fsnode.stub == null) {
	        	System.out.println("Waiting for FS Node to start up: " + fsnode.nodename);
	        	Thread.sleep(100);
	        }
        }
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testAlive() {
		for (FSNodeImpl fsnode : this.fsnodeVector) {
			try {
				assertTrue(fsnode.stub.isAlive());
			} catch (RemoteException e) {
				fail(e.getStackTrace().toString());	
			}
		}
	}
	
	@Test
	public void testLargeWriteReadWorks() {
		try {
			// Write test data
			File tempfile = this.folder.newFile();
			Util.writeTestFile(30000000L, tempfile); // 30MB of text
			this.fsnodeVector[0].stub.writeFile(tempfile);

			// Get records from FSNode
			String[] filenames = new String[1];
			filenames[0] = tempfile.getName();
			
			// MACHINE 1
			Record[] records = this.fsnodeVector[0].stub.recordsOfFiles(filenames);
			
			for (Record record : records) {
				// Read and assert consistency
				RecordReader rr = new RecordReader(record, this.fsnodeVector[0]);
				rr.initialize();
				int count = 0;
				do {
					assertArrayEquals(rr.getCurrentKey().getBytes(), "Distributed".getBytes());
					assertArrayEquals(rr.getCurrentValue().getBytes(), "systems is awesome.".getBytes());
					count += 1;
				} while (rr.nextKeyValue());
				assertEquals(count, rr.numPairs);
				assertEquals(count, rr.currPairNum);
				rr.close();
			}
			
			// MACHINE 2
			records = this.fsnodeVector[1].stub.recordsOfFiles(filenames);
			
			for (Record record : records) {
				// Read and assert consistency
				RecordReader rr = new RecordReader(record, this.fsnodeVector[1]);
				rr.initialize();
				int count = 0;
				do {
					assertArrayEquals(rr.getCurrentKey().getBytes(), "Distributed".getBytes());
					assertArrayEquals(rr.getCurrentValue().getBytes(), "systems is awesome.".getBytes());
					count += 1;
				} while (rr.nextKeyValue());
				assertEquals(count, rr.numPairs);
				assertEquals(count, rr.currPairNum);
				rr.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
			fail();
		}
	}

} 

