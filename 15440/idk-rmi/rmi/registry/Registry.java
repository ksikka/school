package rmi.registry;

import java.util.*;
import java.net.*;
import java.io.*;

import rmi.ROR;
import rmi.messaging.*;

public class Registry implements Runnable {
    public HashMap<String, ROR> rorMap;
    ServerSocket socket;

    int port;

    //Registry has a hashmap of name to ROR types
    public Registry(int port) throws IOException{
        rorMap = new HashMap<String, ROR>();
        this.port = port;

        //
        socket = new ServerSocket(port);
    }

    public void serveForever() throws IOException{
        Socket client = null;
        while (true) {
            client = this.socket.accept();
            RMIMessage req = null;

            try {
                //read in an object
                ObjectInputStream ois = new ObjectInputStream(client.getInputStream());
                req = (RMIMessage) ois.readObject();
                //the client this was talking to failed so just keep
                //running
            } catch (IOException e){
                System.out.println("Failed to read message: "+e);
                continue;
                //problem with RMI facility, fail
            } catch (ClassNotFoundException e){
                System.out.println("Class not found");
                System.exit(1);
            }

            //create a response message 
            RMIMessage resp = null;

            //received a message to register a new ROR
            //check if already in database, if not then add it 
            if (req.type.equals(MessageType.REGISTERROR)) {
                if (this.rorMap.containsKey(req.key)) {
                    resp = new RMIMessage(MessageType.DUPLICATE_KEY);
                } else {
                    this.rorMap.put(req.key, req.ror);
                    resp = new RMIMessage(MessageType.OK);
                }
            //received a request to lookup a ROR
            //if found return it
            //otherwise say not found  
            } else if (req.type.equals(MessageType.LOOKUPROR)) {
                if (this.rorMap.containsKey(req.key)) {
                    resp = new RMIMessage(MessageType.RORRESULT, this.rorMap.get(req.key));
                } else {
                    resp = new RMIMessage(MessageType.RORNOTFOUND);
                }
            //recieved a ping message
            //respond ok
            } else if (req.type.equals(MessageType.PING)) {
                resp = new RMIMessage(MessageType.OK);
            } else {
                System.out.println("Registry server got an unrecognized message");
                System.exit(1);
            }

            //send back the response message
            try {

                ObjectOutputStream oos = new ObjectOutputStream(client.getOutputStream());
                oos.writeObject(resp);
            } catch (IOException e){
                System.out.println("Failed to send message");
            }
        }
    }

    public void run(){
        try{
            this.serveForever();
        }
        catch (IOException e){
            System.out.println("Couldn't start the Registry");
            System.exit(1);
        }
    }
}
