package cookiemonster.dfs;

import java.io.File;
import java.io.ObjectInputStream;
import java.io.FileInputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;
import java.net.ServerSocket;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;

import cookiemonster.dfs.exceptions.MasterUnreachableException;
import cookiemonster.dfs.exceptions.OutOfSpaceException;


public class FileServer implements Runnable {

	InetSocketAddress isa;
	FSNodeImpl node; // The FSNode on which this file server is running.
	
	public FileServer(FSNodeImpl node) {
		this.node = node;
		this.isa = null;
	}

	@Override
	public void run() {
		ServerSocket serverSock = null;
		try {
			serverSock = new ServerSocket(0);
		} catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
		}
		assert serverSock != null;
		try {
			this.isa = new InetSocketAddress(InetAddress.getLocalHost(), serverSock.getLocalPort());
		} catch (UnknownHostException e1) {
			throw new RuntimeException(e1);
		}
		
		Socket clientSock;
		while (true) {
			try {
				clientSock = serverSock.accept();
	
				// Get path of file I'm supposed to serve
				ObjectInputStream dis = new ObjectInputStream(clientSock.getInputStream());
				Record r = (Record) dis.readObject();
				assert r != null;
				File srcFile = this.node.getRecordFile(r);
	
				// Serve the file
	            FileInputStream fis = new FileInputStream(srcFile);
	            BufferedInputStream bis = new BufferedInputStream(fis);
	            BufferedOutputStream bos = new BufferedOutputStream(clientSock.getOutputStream());
	            
	            int b = bis.read();
	            while(b != -1) {
	            	bos.write(b);
	            	b = bis.read();
	            }
	            bis.close();
	            bos.flush();
	            clientSock.close();
	        } catch (IOException e) {
	        	e.printStackTrace();
	        } catch (ClassNotFoundException e) {
				// impossible since we always send a RemoteRecord when we ask to download (see download code in FSNodeImpl)
				e.printStackTrace();
			} catch (OutOfSpaceException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (MasterUnreachableException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}
