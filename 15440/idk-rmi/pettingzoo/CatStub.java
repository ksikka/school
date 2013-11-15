package pettingzoo;

import rmi.Stub;
import rmi.messaging.*;
import rmi.RMIException;
import java.net.UnknownHostException;
import java.io.IOException;

public class CatStub extends Stub {

    public String feed(String arg0) throws RMIException {
        String[] argArray = new String[1];
        Class[] classArray = new Class[1];

        // for every argument...
        argArray[0] = arg0;

        try{
            // for every argument...
            classArray[0] = Class.forName("java.lang.String"); //special case for string
        }
        catch (ClassNotFoundException e){
            // This never happens if we assume the stub compiler is correct.
            System.out.println("Fatal: Stub compiler incorrect");
            System.exit(1);
        }

        RMIMessage m = new RMIMessage(MessageType.INVOKEMETHOD, "feed",
            super.ror, argArray, classArray);

        Object response = super.sendInvocationMessage(m);
        return (String)(response); // to return type of the method
    }

    public Animal reproduce() throws RMIException {
        String[] argArray = new String[0];
        Class[] classArray = new Class[0];

        RMIMessage m = new RMIMessage(MessageType.INVOKEMETHOD, "reproduce", // name of method here
            super.ror, argArray, classArray);

        Object response = super.sendInvocationMessage(m);
        return (Animal)(response); // to return type of the method
    }

    public void poop() throws Exception{
        String[] argArray = new String[0];
        Class[] classArray = new Class[0];

        RMIMessage m = new RMIMessage(MessageType.INVOKEMETHOD, "poop", // name of method here
            super.ror, argArray, classArray);

        Object response = super.sendInvocationMessage(m);
        throw (Exception)(response); // to return type of the method
    }

}
