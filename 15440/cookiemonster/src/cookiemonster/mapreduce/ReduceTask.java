package cookiemonster.mapreduce;

import java.io.Serializable;

import cookiemonster.dfs.Record;

public class ReduceTask implements Serializable {
	
	int groupNum;
	Job job;
	Reducer reduce;
	
	public ReduceTask(Reducer reducefunction, int groupNum, Job job){
		this.groupNum = groupNum;
		this.reduce = reducefunction;
		this.job = job;
	}

}
