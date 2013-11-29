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
import java.util.HashMap;

import java.io.File;
import java.io.IOException;

public class FileSystemTestCase {
	@Rule
	public TemporaryFolder folder = new TemporaryFolder();
	
	public FSManagerImpl fsman;
	public FSNodeImpl fsnode;
	public Thread FSNodeThread;
	public Thread FSManagerThread;
	
	/* TESTS BASIC: 1 MASTER 1 SLAVE CONFIG WITH REPLICATION = 1 AND RECORD SIZE = 3MB */
	@Before
	public void setUp() throws Exception {
		// Set up this VM to be able to use RMI
        Util.preRMISetup(FSNodeImpl.class);
        
        Registry registry = LocateRegistry.getRegistry();
        FSNodeImpl.registry = registry;
        
        HashMap<String, String> confighash = new HashMap<String, String>();
        confighash.put("replication_factor", "1");
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

        File workingDir = this.folder.newFolder("working_dir");
        
        FSNodeImpl obj = new FSNodeImpl("edwin", workingDir, fmanimpl.stub, new FSNodeConfig(confighash));
        t = new Thread(obj);
        t.start();
        this.fsnode = obj;

        this.FSNodeThread = t;
        while(this.fsnode.stub == null) {
        	System.out.println("Waiting for FS Node to start up");
        	Thread.sleep(100);
        }
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testAlive() {
		try {
			assertTrue(this.fsnode.stub.isAlive());
		} catch (RemoteException e) {
			fail(e.getStackTrace().toString());	
		}
	}
	
	@Test
	public void testSmallWriteReadWorks() {
		try {
			// Write test data
			File tempfile = this.folder.newFile();
			Util.writeTestFile(3000000L, tempfile); // 3MB of text
			this.fsnode.stub.writeFile(tempfile);

			// Get records from FSNode
			String[] filenames = new String[1];
			filenames[0] = tempfile.getName();
			Record[] records = this.fsnode.stub.recordsOfFiles(filenames);
			
			// Read and assert consistency
			RecordReader rr = new RecordReader(records[0], this.fsnode);
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
		} catch (Exception e) {
			e.printStackTrace();
			fail();
		}
	}
	
	@Test
	public void testLargeWriteReadWorks() {
		try {
			// Write test data
			File tempfile = this.folder.newFile();
			Util.writeTestFile(30000000L, tempfile); // 30MB of text
			this.fsnode.stub.writeFile(tempfile);

			// Get records from FSNode
			String[] filenames = new String[1];
			filenames[0] = tempfile.getName();
			Record[] records = this.fsnode.stub.recordsOfFiles(filenames);
			
			for (Record record : records) {
				// Read and assert consistency
				RecordReader rr = new RecordReader(record, this.fsnode);
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
