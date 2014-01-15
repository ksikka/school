package cookiemonster.dfs;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.rmi.RemoteException;

import cookiemonster.dfs.exceptions.FileNotFoundException;
import cookiemonster.dfs.exceptions.MalformedRecordException;
import cookiemonster.dfs.exceptions.MasterUnreachableException;
import cookiemonster.dfs.exceptions.OutOfSpaceException;

public class DFSFileReader {

	String filename;
	
	Record[] records;
	int currIndex; // Current record index;
	Record currRecord;
	
	FSNode node;
	File localfile;
	
	public int currPairNum;
	public int numPairs;
	private BufferedReader br;

	String content; // TODO implement buffered line reading.
	private String currKey;
	private String currValue;

	public DFSFileReader(String filename, FSNode node) throws MasterUnreachableException {
	    this.filename = filename;
	    
	    String[] filenameArr = new String[1];
	    filenameArr[0] = filename;

	    try {
	    	this.records = node.recordsOfFiles(filenameArr);
	    	System.out.println("RRRR " + this.filename);
	    	for (int i = 0; i < records.length; i++) {
	    		System.out.println(records[i]);
	    	}
	    } catch (RemoteException e) {
	    	throw new MasterUnreachableException(e);
	    }
	    this.currRecord = records[0];
	    
	    this.node = node;
	    this.currPairNum = 0;
	}
	
	/* Call once before using the methods */
	public void initialize() throws MasterUnreachableException, FileNotFoundException, OutOfSpaceException, IOException, MalformedRecordException {
	    this.localfile = this.node.getRecordFile(this.currRecord);
	    
	    // count lines
		this.br = new BufferedReader(new FileReader(this.localfile));
		this.numPairs = 0;
		int ccode = br.read();
		while (ccode != -1) {
			if (ccode == (int)'\n') this.numPairs += 1;
			ccode = br.read();
		}

		// recreate br because file pointer is at the end
		this.br = new BufferedReader(new FileReader(this.localfile));
		
		// read one key/value to prime the pump
		this.nextKeyValue();
	}

	/* Close the file reader. */
	public void close() {
		try {
			this.node.releaseRemoteRecord(this.currRecord);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/* Get the current key */
	public String getCurrentKey() {
		return this.currKey;
	} 
    
	/* Get the current value. */
	public String getCurrentValue() {
		return this.currValue;
	}
	
	/* Closes this record and goes onto the next one */
	public boolean nextRecord() throws MasterUnreachableException, FileNotFoundException, OutOfSpaceException, IOException, MalformedRecordException {
		if (this.currIndex == this.records.length - 1) {
			return false;
		}
		this.close();
		this.currIndex += 1;
		this.currRecord = this.records[this.currIndex];
		this.initialize();
		return true;
	}
	
    /* Read the next key, value pair. */
	public boolean nextKeyValue() throws IOException, MalformedRecordException, MasterUnreachableException, FileNotFoundException, OutOfSpaceException {
		System.out.println("Reading from " + this.filename);
		if (this.localfile == null) {
			// Please call initialize before using these methods.
			throw new NullPointerException();
		}
		String content = this.br.readLine();
		if (content == null)
			return this.nextRecord();
		System.out.println("From dfs filereader: " + content);
		String[] tokens = content.split(" ", 2);
		if (tokens.length == 0) {
			return this.nextRecord();
		} else if (tokens.length == 1) {
      if (tokens[0].equals(""))
        return this.nextRecord();
			throw new MalformedRecordException(this.currRecord, content);
		} else {
			this.currKey = tokens[0];
			this.currValue = tokens[1];
			this.currPairNum += 1;
			return true;
		}
	}
}
