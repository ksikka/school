package cookiemonster;

import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.PriorityQueue;
import java.util.Comparator;

import cookiemonster.dfs.DFSFileReader;

public class Util {
	public static final String SEC_POLICY = "grant { permission java.security.AllPermission; };";
	
	/* Return the path to a security policy file (tempfile) */
	public static String getPolicyFilePath() throws IOException {
        File tempFile = File.createTempFile("rmi-base", ".policy");
        BufferedWriter writer = new BufferedWriter(new FileWriter(tempFile));
        writer.write(Util.SEC_POLICY);
        writer.close();
        tempFile.deleteOnExit();
        return tempFile.getAbsolutePath();
    }
	
	/* Set up system properties and a security manager needed for an RMI Server */
	public static void preRMISetup(Class startClass) throws IOException {
		System.setProperty("java.rmi.server.codebase", startClass.getProtectionDomain().getCodeSource().getLocation().toString());
        System.setProperty("java.security.policy", Util.getPolicyFilePath());

        if(System.getSecurityManager() == null) {
            System.setSecurityManager(new SecurityManager());
        }
	}
	
	/* Create a file with a given number of bytes, for testing purposes.
	 * Will write "Distributed systems is awesome.\n" repeatedly. */
	public static void writeTestFile(long numBytes, File destFile) throws Exception {
		BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(destFile.getAbsolutePath()));
		long bytesWritten = 0;
		byte[] bytes = "Distributed systems is awesome.\n".getBytes();
		while(bytesWritten != numBytes) {
			if ((bytes.length + bytesWritten) > numBytes) {
				int numBytesToWrite = (int) (numBytes - bytesWritten);
				bos.write(bytes, 0, numBytesToWrite);
				bytesWritten += numBytesToWrite;
			} else {
				bos.write(bytes);
				bytesWritten += bytes.length;
			}
		}
		bos.close();
	}
	
	/* Convenience function to parse a string into key - value */
	public static HashMap<String, String> parseConfig(String[] lines) throws ConfigSyntaxError {
		HashMap<String, String> configHash = new HashMap<String, String>();
		for (String l : lines) {
			if (l.equals("")) continue;
			String[] tokens = l.split(" ", 2);
			if (tokens.length != 2) {
				throw new ConfigSyntaxError();
			} else {
				configHash.put(tokens[0], tokens[1]);
			}
		}
		return configHash;
	}
	
	/*K-Way Merge algorithm used to merge local files after map as well
	 * As files in the DFS for reduce step. Input an array of files that all pertain to
	 * one job and one reduce group number. Writes the final resulting file to the dfs.
	 */
	
	public static void kWayMerge(ArrayList<DFSFileReader> files, BufferedWriter b) throws IOException{
		
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
		
		//take out the min value from the tree, write to buffered writer and replace in the tree
		//repeat until the tree is empty 
		while(!minHeap.isEmpty()){
			MergeEntry pair = minHeap.remove();
			String line = pair.key + " " + pair.value;
			System.out.println("In main, line "+ line);
			b.write(line);
			b.newLine();
			
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
		//close the writer
		
		b.close();
		
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
