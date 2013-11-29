package cookiemonster.dfs.exceptions;

import java.rmi.RemoteException;

public class MasterUnreachableException extends Exception {
	RemoteException e;
	public MasterUnreachableException(RemoteException e) {
		this.e = e;
	}
}
