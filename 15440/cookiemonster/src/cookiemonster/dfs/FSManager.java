package cookiemonster.dfs;

import java.io.File;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.HashMap;

import cookiemonster.dfs.exceptions.FileNotFoundException;
import cookiemonster.dfs.exceptions.OutOfSpaceException;

public interface FSManager extends Remote {


    public void registerNode(String nodename, FSNode fsnode) throws RemoteException;
    
	public HashMap<String, Integer> ls() throws RemoteException;

	public void registerReplicas(Replica[] replicas) throws RemoteException;
	public Replica[] getReplicasOfRecord(Record r) throws RemoteException;

	public FSNode getNodeOfRecord(Record r)
    		throws RemoteException, FileNotFoundException;
	
	public void newFile(String name, Integer recordCnt) throws RemoteException;
	public void newFiles(HashMap<String, Integer> miniFileRecordCnt) throws RemoteException;

	public FSManagerConfig getConfig() throws RemoteException;

	public void rebalanceReplicas(FSNode node) throws RemoteException, OutOfSpaceException;

}
