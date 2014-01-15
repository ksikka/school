package cookiemonster.dfs;

import java.net.InetSocketAddress;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.io.InputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

import cookiemonster.dfs.Record;
import cookiemonster.dfs.exceptions.FileNotFoundException;
import cookiemonster.dfs.exceptions.MasterUnreachableException;
import cookiemonster.dfs.exceptions.OutOfSpaceException;

public interface FSNode extends Remote {


    public File getRecordFile(Record r)
    		throws RemoteException, MasterUnreachableException, FileNotFoundException, OutOfSpaceException;
    
    public void writeFile(File f)
    		throws RemoteException, MasterUnreachableException, IOException, OutOfSpaceException;
    
    public String[] ls() throws RemoteException;
    
    public Record[] recordsOfFiles(String[] filenames)
    		throws RemoteException, MasterUnreachableException; 
    
	boolean isAlive() throws RemoteException;
	
	public void createReplicaOf(Replica replica)
			throws RemoteException, IOException, OutOfSpaceException, MasterUnreachableException;

	public InetSocketAddress getftpisa() throws RemoteException;

	public void releaseRemoteRecord(Record r) throws RemoteException;
	
    public void removeLocalReplica(Record r) throws RemoteException, MasterUnreachableException;

    
}
