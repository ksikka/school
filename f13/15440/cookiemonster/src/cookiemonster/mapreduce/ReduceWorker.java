package cookiemonster.mapreduce;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.PriorityQueue;
import java.util.logging.Logger;

import cookiemonster.dfs.DFSFileReader;
import cookiemonster.dfs.FSNode;

public class ReduceWorker implements Runnable {

	ReduceTask reduceTask;
	FSNode fsnode;
	private static Logger LOGGER = Logger.getLogger(JobManagerImpl.class.getName());
	
	public ReduceWorker(ReduceTask reducetask, FSNode fsnode){
		this.reduceTask = reducetask;
		this.fsnode = fsnode;
	}
	@Override
	public void run() {
		// TODO Auto-generated method stub
		try {
			String[] files = this.fsnode.ls();
			ArrayList<DFSFileReader> relevantFiles = new ArrayList<DFSFileReader>();
			for (String s : files){
				if(s.startsWith("combiner-" + this.reduceTask.job.jid + "-" 
						+ Integer.toString(this.reduceTask.groupNum))) {
          LOGGER.info("Found the combiner file.");
					relevantFiles.add(new DFSFileReader(s, this.fsnode));
				}
			}

      LOGGER.info("Reducemerged files: " + relevantFiles.size());
      if (relevantFiles.size() > 0) {
        String fileName = "Final-" + this.reduceTask.job.jid + "-" +
            Integer.toString(this.reduceTask.groupNum);
        File temp = new File("/tmp/cookiemonster/" + fileName);
        BufferedWriter bw = new BufferedWriter(new FileWriter(temp));
    
        kWayMergeAndReduce(relevantFiles, bw);
        bw.close();
        this.fsnode.writeFile(temp);
      }
			
		} catch (Exception e) {
      e.printStackTrace();
			throw new RuntimeException(e);
		}
		
	}
	
public void kWayMergeAndReduce(ArrayList<DFSFileReader> files, BufferedWriter bw) throws IOException{
		
		//key --> [value, FileReaderNum]
		PriorityQueue<MergeEntry> minHeap = new PriorityQueue<MergeEntry>(files.size(), new MergeEntryComparator());
		
		//initialize the tree with one value from each file
		for(int i = 0; i < files.size(); i++){
			try {
				files.get(i).initialize();
			} catch (Exception e) {
				throw new RuntimeException();
			}
			String key = files.get(i).getCurrentKey();
			String value = files.get(i).getCurrentValue();
			
			minHeap.add(new MergeEntry(key, value, i));
			
		}
		
		//take out the min value from the tree, add to the current reduce task to run reduce on
		//then move on to next key
		ArrayList<String> currentReduceValues = new ArrayList<String>();
		String currentKey = null;
		while(!minHeap.isEmpty()){

			MergeEntry pair = minHeap.remove();
			//this is the first run
			if(currentKey == null){
				currentKey = pair.key;
				currentReduceValues.add(pair.value);
			}
			//not first run
			else{
				String key = pair.key;
				//same reduce set
				if(key.equals(currentKey)){
					currentReduceValues.add(pair.value);
				}
				//not the same reduce set we just got a new key!!
				else{
					bw.write(currentKey + " " + this.reduceTask.reduce.reduce(currentKey, currentReduceValues));
					bw.newLine();
					currentReduceValues.clear();
					currentKey = key;
					currentReduceValues.add(pair.value);
				}
			}
			
			//replace value from the correct file if possible
			int fileNum = pair.index;
			boolean isDone;
			try {
				isDone = ! files.get(fileNum).nextKeyValue();
			} catch (Exception e) {
				throw new RuntimeException();
			}
			if(! isDone){
				String key = files.get(fileNum).getCurrentKey();
				String value = files.get(fileNum).getCurrentValue();
					
				minHeap.add(new MergeEntry(key, value, fileNum));	
			}
			
		}
		bw.write(currentKey + " " + this.reduceTask.reduce.reduce(currentKey, currentReduceValues));
		bw.newLine();
	
		
		
	}

}

class MergeEntry {
	public String key;
	public String value;
	public int index;
	public MergeEntry(String key, String value, int index) {
		this.key = key;
		this.value = value;
		this.index = index;
	}
}
class MergeEntryComparator implements Comparator<MergeEntry> {

	@Override
	public int compare(MergeEntry arg0, MergeEntry arg1) {
		return arg0.key.compareTo(arg1.key);
	}
	
}
