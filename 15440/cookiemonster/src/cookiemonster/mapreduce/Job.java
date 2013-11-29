package cookiemonster.mapreduce;

import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;

public class Job implements Serializable {
	
	public enum Status{
		NOTSTARTED, INPROGMAP, INPROGREDUCE, COMPLETE
	}

   private static final long serialVersionUID = 6529685098267576970L;
	File localInputDir;
	Mapper MapClass;
	Reducer reduceClass;
	ArrayList<String> inputFiles;
	int jid;
	int numReduceGroups;
	int numMapTasks;
	Status status;

  public Job(File localdir, Mapper m, Reducer r) {
    this.localInputDir = localdir;
    this.MapClass = m;
    this.reduceClass = r;
	this.inputFiles = new ArrayList<String>();
	this.status = Job.Status.NOTSTARTED;  
  }

  public String toString() {
    return "Job " + this.jid;
  }
  public int hashCode() {
    return this.toString().hashCode();
  }
  public boolean equals(Object obj) {
    Job j = (Job) obj;
    return j.jid == this.jid;
  }
	

}
