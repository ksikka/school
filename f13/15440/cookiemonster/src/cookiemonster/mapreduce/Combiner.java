package cookiemonster.mapreduce;

import java.io.IOException;
import java.io.File;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.util.ArrayList;
import java.util.logging.Logger;

import cookiemonster.Util;
import cookiemonster.dfs.DFSFileReader;
import cookiemonster.dfs.exceptions.MasterUnreachableException;

public class Combiner implements Runnable {

	private static Logger LOGGER = Logger.getLogger(Combiner.class.getName());

	Job job;
	int reduceGroupIndex;
	TaskManagerImpl taskManagerImpl;

	public volatile double progress;
	public Thread thread;

	public Combiner(Job job, TaskManagerImpl taskManagerImpl) {
		this.job = job;
		this.taskManagerImpl = taskManagerImpl;
		this.progress = 0.0;
	}
	
	public void run() {
		try {
			LOGGER.info("Running a combiner now 'mon. Ja mon. Let's do it.");
			for (int i = 0; i < this.job.numReduceGroups; i ++) {
				ArrayList<DFSFileReader> fileReaders = new ArrayList<DFSFileReader>();
				String[] filenames = this.taskManagerImpl.fsnode.ls();
				for (String fileName : filenames) {
					LOGGER.info("Temp file name: " + fileName);
					String filenameToMatch = this.taskManagerImpl.nodename+ "-"+  this.job.jid + "-" + Integer.toString(i) + "-";
					LOGGER.info(filenameToMatch);
					if (fileName.startsWith(filenameToMatch)) {
						LOGGER.info("In starts with!!! " + fileName);
						fileReaders.add(new DFSFileReader(fileName, taskManagerImpl.fsnode));
					}
				}
				LOGGER.info("Done adding filereaders: " + fileReaders.size());
        if (fileReaders.size() > 0) {

          File destFile = new File("/tmp/cookiemonster/" + "combiner-" + this.job.jid 
                + "-" + Integer.toString(i) + "-" + this.taskManagerImpl.nodename, "");
          BufferedWriter b = new BufferedWriter(new FileWriter(destFile));
          Util.kWayMerge(fileReaders, b);
          this.taskManagerImpl.fsnode.writeFile(destFile);
        }

			}
		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		}
	}

}
