package cookiemonster.mapreduce;

import cookiemonster.dfs.FSNode;
import cookiemonster.dfs.Record;
import java.io.Serializable;

import java.util.concurrent.Callable;
public class MapTask implements Serializable {
	
	public enum Status {
	    NOTSTARTED, INPROG, WAITFORCOMBINE, COMBINING, COMPLETE
	}
	volatile int numReduceGroups;
	volatile Mapper map;
	volatile Record record;
	volatile Job job;
	volatile Status status;
	volatile int mapId;
	
	public MapTask(Mapper mapfunction, Record record, Job job, Status s, int mapId){
		this.job = job;
		this.numReduceGroups = this.job.numReduceGroups;
		this.map = mapfunction;
		this.record = record;
		this.status = s;
		this.mapId = mapId;
	}

	public void updateWithNewTask(MapTask newTask) {
		this.status = newTask.status;
	}

  public String toString() {
    return "Maptask " + this.mapId;
  }
  public int hashCode() {
    return this.toString().hashCode();
  }
  public boolean equals(Object obj) {
    MapTask m = (MapTask) obj;
    return m.mapId == this.mapId;
  }
	

}
