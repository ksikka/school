package rmi.registry;

import java.net.*;
import java.io.*;

import rmi.ROR;
import rmi.messaging.*;
import rmi.Stub;


// a client to talk to the registry. It is in each RMI server as well as
// used by the real 'client' to communicate and get a ROR
public class RegistryClient {

    String host;
    int port;

    public RegistryClient(String host, int port) throws UnknownHostException, IOException{    
        this.host = host;
        this.port = port;

        //check if it is able to reach the registry
        this.ping();
    }

    //send a message to the registry
    private RMIMessage sendMessage(RMIMessage m) throws UnknownHostException, IOException {
        Socket socket = new Socket(this.host, this.port);

        //send a message 
        ObjectOutputStream oos = new ObjectOutputStream(socket.getOutputStream());
        oos.writeObject(m);

        RMIMessage resp = null;

        //try to get the response
        try{
            ObjectInputStream ois = new ObjectInputStream(socket.getInputStream());
            resp = (RMIMessage) ois.readObject();
            return resp;
        }
        //RMI internal problem, exit
        catch (ClassNotFoundException e){
            System.exit(1);
        }
        return resp;
    }

    //ping the registry
    //if it fails throw exception
    public int ping() throws UnknownHostException, IOException{
        // pings the registry server for its status
        RMIMessage m = new RMIMessage(MessageType.PING);
        RMIMessage resp = this.sendMessage(m);
        if (resp.type.equals(MessageType.OK)) {
            return 0;
        }
        throw new java.net.UnknownHostException();
    }

    //lookup a stub with a given key
    //it creates a message and sends it and then gets the ROR back and 
    //creates a stub from the ROR and returns it.
    public Stub lookupStub(String key) throws UnknownHostException, IOException{
        // asks the registry server for the remote object ref
        RMIMessage m = new RMIMessage(MessageType.LOOKUPROR, key);
        RMIMessage resp = this.sendMessage(m);
        if (resp.type == MessageType.RORRESULT) {
            ROR ror = resp.ror;
            Stub respStub = (Stub)resp.ror.createStub();
            respStub.ror = ror;
            return respStub;
        }
        else {
            System.out.println("Failed to lookup a stub");
            System.exit(1);
        }
        return null; // will never happen, just calms down compiler
    }

    //register a new ROR, send message and receive respond letting us know
    //it was succesful
    public int registerRor(String key, ROR ror) throws UnknownHostException, IOException{
        // send message to registry server about this key, ror pair
        RMIMessage m = new RMIMessage(MessageType.REGISTERROR, key, ror);
        RMIMessage resp = this.sendMessage(m);
        if (resp.type == MessageType.OK) {
            return 0;
        }
        else {
            return 1;
        }
    }

}
