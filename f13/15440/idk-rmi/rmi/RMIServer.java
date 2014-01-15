package rmi;

import java.util.*;
import java.net.*;
import java.io.*;

import rmi.ROR;
import rmi.registry.RegistryClient;
import java.lang.reflect.Method;
import rmi.messaging.*;

//RMI Server exists in each server with remote objects
//serves the role of communications between clients and the
//objects   
public class RMIServer implements Runnable {
    private HashMap<String, Object> rorMap;
    RegistryClient rc;
    ServerSocket socket;
    int port;
    String hostname;

    //starts up its own registry client because they all have one
    public RMIServer(String hostname, int port, String registryhost, int registryport) throws IOException, ClassNotFoundException{
        rorMap = new HashMap<String, Object>();
        this.port = port;
        this.rc = new RegistryClient(registryhost, registryport);
        this.hostname = hostname;
        this.socket = new ServerSocket(port);

    }

    //addobj to the local database of ROR's
    public void addObj(String key, Object obj, String className) throws UnknownHostException, IOException, ClassNotFoundException{
        // make ROR for obj
        ROR ror = new ROR(this.hostname, this.port, key, className);
        this.rorMap.put(ror.objkey, obj);

        // tell registry (via this.rc) about it
        this.rc.registerRor(key, ror);

    }

    //calls method so that it can return to client
    public Object call_method_by_name(Object obj, String methodName, Class[] argClasses, Object[] args) throws Exception{

        Method method = null;
        try {
            method = obj.getClass().getMethod(methodName, argClasses);
        } catch (SecurityException e) {
            System.out.println(e);
            System.exit(1);
        } catch (NoSuchMethodException e) {
            System.out.println(e);
            System.exit(1);
        }

        Object returnValue = null;
        try {
            returnValue = method.invoke(obj, args);
            return returnValue;

        //throw up the exception that is returned by the method
        } catch (IllegalAccessException e) {
            System.out.println(e);
        } catch (IllegalArgumentException e) {
            System.out.println(e);
        } catch (java.lang.reflect.InvocationTargetException e) {
            throw (Exception)e.getTargetException();
        } catch (NullPointerException e) {
            System.out.println(e);
        } catch (ExceptionInInitializerError e) {
            System.out.println(e);
        }
        System.exit(1);
        return returnValue;
    }

    public void serveForever() {
        // runs the server on this.port
        Socket client = null;

        while (true) {
            try {
                client = this.socket.accept();
            } catch (IOException e) {
                System.out.println("Accept failed");
                System.exit(1);
            }
            RMIMessage req = null;

            //gets a message
            try {
                ObjectInputStream ois = new ObjectInputStream(client.getInputStream());
                req = (RMIMessage) ois.readObject();
            } catch (IOException e){
                System.out.println("Failed to read message2");
                continue;
            } catch (ClassNotFoundException e){
                System.out.println("Class not found");
                System.exit(1);
            }
            RMIMessage returnMessage = null;

            //gets the object from it's own database using the ror in the message 
            //and invokes it and returns it to the caller
            Object o = this.rorMap.get(req.ror.objkey);
            if (o == null) {
                System.out.println("Ror with key " + req.ror.objkey +" not found.");
                returnMessage = new RMIMessage(MessageType.RORNOTFOUND);
            } else {
                try {
                    Object result = call_method_by_name(o, req.method, req.argtypes, req.args);
                    returnMessage = new RMIMessage(MessageType.RETURN, result);
                } catch (Exception e) {
                    returnMessage = new RMIMessage(MessageType.EXCEPTION, e);
                }
            }
            try{
                ObjectOutputStream oos = new ObjectOutputStream(client.getOutputStream());
                oos.writeObject(returnMessage);
            }
            catch (IOException e){
                System.out.println("Failed to send message");
            }

        }


    }

    public void run() {

        this.serveForever();
    }
}
