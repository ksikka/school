package examples.WordCount;

import java.io.File;

import cookiemonster.mapreduce.Job;
import cookiemonster.mapreduce.JobClient;
import cookiemonster.mapreduce.Mapper;
import cookiemonster.mapreduce.Reducer;

public class WordCountProgram{
	
	public static void main(String[] argv){
		File localdir = new File(argv[0]);
    String nodename = argv[1];
		String reghost = argv[2];
		int regport = Integer.parseInt(argv[3]);

		Mapper m = new WordCountMapper();
		Reducer r = new WordCountReducer();
		Job job = new Job(localdir, m, r);
		
		JobClient.submitJob(job, reghost, regport, nodename);
	}

}
