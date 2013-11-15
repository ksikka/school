package rmi;

import java.net.Socket;
import java.net.ServerSocket;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.ObjectStreamException;
import java.net.UnknownHostException;
import java.io.IOException;

import rmi.messaging.RMIMessage;
import rmi.messaging.MessageType;

import rmi.ROR;

public class Stub {

    // Note: this attribute typically gets set by a RegistryClient so there is no initializing code here.
    public ROR ror;

    public Stub() {
    }

    public Object sendInvocationMessage(RMIMessage m) throws RMIException {
        try {
            Socket socket = new Socket(this.ror.host, this.ror.port);
            ObjectOutputStream oos = new ObjectOutputStream(socket.getOutputStream());
            oos.writeObject(m);

            ObjectInputStream ois = new ObjectInputStream(socket.getInputStream());
            RMIMessage resp = (RMIMessage) ois.readObject();

            if(resp.type == MessageType.EXCEPTION){
                return resp.exception;
            }
            return resp.returnObj;
        }
        catch (UnknownHostException e){
            throw new RMIException(e);
        }
        catch (IOException e){
            throw new RMIException(e);
        }
        catch (ClassNotFoundException e){
            System.out.println("Fatal: RMI Message passing bug");
            System.exit(1);
        }
        return null; // this never happens. keep compiler quiet
    }

}
