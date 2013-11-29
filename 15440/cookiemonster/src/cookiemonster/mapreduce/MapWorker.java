package cookiemonster.mapreduce;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.TypeVariable;
import java.rmi.AccessException;
import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.ArrayList;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.Logger;
import java.util.TreeMap;

import cookiemonster.dfs.FSNode;
import cookiemonster.dfs.RecordReader;
import cookiemonster.dfs.exceptions.FileNotFoundException;
import cookiemonster.dfs.exceptions.MalformedRecordException;
import cookiemonster.dfs.exceptions.MasterUnreachableException;
import cookiemonster.dfs.exceptions.OutOfSpaceException;

public class MapWorker implements Runnable{

	MapTask mapTask;
	FSNode fsnode;
	String nodename;
	private static Logger LOGGER = Logger.getLogger(MapWorker.class.getName());
	
	public MapWorker(String nodename, MapTask maptask, FSNode fsnode){
		this.mapTask = maptask;
		this.fsnode = fsnode;
		this.nodename = nodename;
	}
	
	// Complete the maptask then writes to local file
	@Override
	public void run() {
		try {
			RecordReader reader = new RecordReader(this.mapTask.record, this.fsnode);
			TreeMap<String, ArrayList<String>> result = new TreeMap<String, ArrayList<String>>();
			
	
			reader.initialize();
			boolean isNotDone = false;
			do{
				String key = reader.getCurrentKey();
				String value = reader.getCurrentValue();
        LOGGER.info(String.format("Passing key/value to Map fn: (%s, %s)", key, value));
				
				ArrayList<Entry<String, String>> mapresult = this.mapTask.map.map(key, value);
		        // TODO what if mapresult is null :(
		        for (Entry<String, String> pair : mapresult) {
		          String mapkey = pair.getKey();
		          ArrayList<String> currCollectedValues = result.get(mapkey);
		          if (currCollectedValues == null) {
		            currCollectedValues = new ArrayList<String>();
		            currCollectedValues.add(pair.getValue());
		            result.put(mapkey, currCollectedValues);
		          } else {
		            currCollectedValues.add(pair.getValue());
		          }
		        }
	
				isNotDone = reader.nextKeyValue();

			} while (isNotDone);
			
			String jobid = Integer.toString(this.mapTask.job.jid);
			String mapid = Integer.toString(this.mapTask.mapId);
			
	    	//create temp files
			ArrayList<BufferedWriter> tempwriters = new ArrayList<BufferedWriter>();
			for (int i = 0; i < this.mapTask.job.numReduceGroups; i ++) {
				// Note: we rely on the following naming scheme to retrieve the file later in Combiner
				String fileName = this.nodename + "-" + jobid + "-" + Integer.toString(i) + "-" + mapid;
				File temp = new File("/tmp/cookiemonster/" + fileName);
				BufferedWriter bw = new BufferedWriter(new FileWriter(temp));
				tempwriters.add(bw);
			}

			//write keys and values to temporary files
			while(!result.isEmpty()){
				Entry<String, ArrayList<String>> pair = result.pollFirstEntry();
				int reduceNum = Math.abs(pair.getKey().hashCode() % this.mapTask.job.numReduceGroups);
        BufferedWriter tw = tempwriters.get(reduceNum);
        for (String value : pair.getValue()) {
          String line = pair.getKey().toString()+ " " + value.toString();
          tw.write(line);
          tw.newLine();
        }
			}
    	    
			for (BufferedWriter b : tempwriters){
				b.close();
			}

			// write files to DFS
			for (int i = 0; i < this.mapTask.job.numReduceGroups; i ++) {
				String fileName = this.nodename + "-" + jobid + "-" + Integer.toString(i) + "-" + mapid;
				LOGGER.info("MapWorker just created file: " + fileName);
				File temp = new File("/tmp/cookiemonster/" + fileName);
				LOGGER.info("Wrote temp contents in " + temp.toString());
				
				//if file is not empty then write it
				if (!(temp.length() <3)){
					this.fsnode.writeFile(temp);
				}
			}
			
			//send an updated status to the JobManager
			this.mapTask.status = MapTask.Status.WAITFORCOMBINE;
      LOGGER.info("Done. Waiting for combine. Exiting now.");
				
		
		} catch (Exception e) {
			// The TaskManager will notice that MapTask.Status != WAITFORCOMBINE yet the Thread is done.
			// then it should be able to capture and report this error, and retry.
      LOGGER.severe("Runtime exception in MapWorker: " + e.toString());
      e.printStackTrace();
			throw new RuntimeException(e);
		}
		
	}
}
