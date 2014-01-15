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

/* Based on org.apache.hadoop.mapreduce.RecordReader<KEYIN,VALUEIN> */

public class RecordReader {

	Record record;
	FSNode node;
	File localfile;
	public int currPairNum;
	public int numPairs;
	private BufferedReader br;

	String content;
	private String currKey;
	private String currValue;

	public RecordReader(Record r, FSNode node) {
	    this.record = r;
	    this.node = node;
	    this.currPairNum = 0;
	}
	
	/* Call once before using the methods */
	public void initialize() throws MasterUnreachableException, FileNotFoundException, OutOfSpaceException, IOException, MalformedRecordException {
	    this.localfile = this.node.getRecordFile(this.record);
	    
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

	/* Close the record reader. */
	public void close() {
		try {
			this.node.releaseRemoteRecord(this.record);
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

    /* Read the next key, value pair. */
	public boolean nextKeyValue() throws IOException, MalformedRecordException {
		if (this.localfile == null) {
			// Please call initialize before using these methods.
			throw new NullPointerException();
		}
		String content = this.br.readLine();
		if (content == null)
			return false;
		String[] tokens = content.split(" ", 2);
		if (tokens.length == 0) {
			return false;
		} else if (tokens.length == 1) {
      if (tokens[0].equals(""))
        return nextKeyValue();
			throw new MalformedRecordException(this.record, content);
		} else {
			this.currKey = tokens[0];
			this.currValue = tokens[1];
			this.currPairNum += 1;
			return true;
		}
	}
}
