package cookiemonster.mapreduce;
/* Runs on every node and manages the MapWorkers and ReduceWorkers on the nodes */
import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.io.File;

import cookiemonster.dfs.FSNode;

public class JobClient{
	static Registry registry = null;

	public static void submitJob(Job job, String reghost, int regport, String nodename){
		try {
			if (JobClient.registry == null)
				JobClient.registry = LocateRegistry.getRegistry(reghost, regport);
	        JobManager jman = (JobManager) registry.lookup("JobManager");
          FSNode fsnode = (FSNode) JobClient.registry.lookup("FSNode " + nodename);
	        addFilestoDFS(job, fsnode); // bootstrap files to dfs
	        jman.startJob(job);
	        
	        poll(jman, job);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (NotBoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
	}
	
	public static void poll(JobManager jman, Job job){
		while(true){
      try { Thread.sleep(1500); } catch (InterruptedException e) {}
      Job j = null; 
      try {
        j = jman.getJobStatus(job);
      } catch (RemoteException e) {throw new RuntimeException(e);}
			if (j == null){
				System.out.println("Not able to complete job.");
				System.exit(1);
			}
			if (j.status.equals(Job.Status.INPROGMAP)){
				System.out.println("Map in progress...");
			}
			else if(j.status.equals(Job.Status.NOTSTARTED)){
				System.out.println("Job waiting to start...");
			}
			else if(j.status.equals(Job.Status.INPROGREDUCE)){
				System.out.println("Reduce in progress...");
			}
			else{
				System.out.println("Job completed!!");
        break;
			}
		}
		
	}
	public static void addFilestoDFS(Job job, FSNode fsnode){
		File[] inputfiles = job.localInputDir.listFiles();
    for(File file : inputfiles){
      if(file.isFile())
        job.inputFiles.add(file.getName());
        try {
          fsnode.writeFile(file);
        } catch (Exception e) {
          // TODO Auto-generated catch block
          e.printStackTrace();
          throw new RuntimeException(e);
        }
        
    }
    
	}
}



