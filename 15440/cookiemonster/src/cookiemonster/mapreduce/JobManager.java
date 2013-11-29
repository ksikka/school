package cookiemonster.mapreduce;

import java.rmi.Remote;
import java.rmi.RemoteException;


public interface JobManager extends Remote {

	/* Job client will call this to start the job on the mapreduce cluster */
	public void startJob(Job job) throws RemoteException;

	/* Task manager will call this on startup to register itself */
	public void registerTaskManager(String nodename, TaskManager taskmanager) throws RemoteException;
	
	public TaskManagerConfig getConfig() throws RemoteException;

	public Job getJobStatus(Job job) throws RemoteException;
}
