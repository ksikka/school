package cookiemonster.mapreduce;

import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.ArrayList;

public interface TaskManager extends Remote {

	public void AssignMapTask(ArrayList<MapTask> tasksAssigned) throws RemoteException;

	public ArrayList<MapTask> getMapTasks(Job job) throws RemoteException;

	public void AssignReduceTask(ArrayList<ReduceTask> t) throws RemoteException;

}
