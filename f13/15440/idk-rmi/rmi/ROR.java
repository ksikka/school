package rmi;
import java.io.*;

public class ROR implements Serializable
{
    String host;
    int port;
    String objkey;
    String className;

    public ROR(String host, int p, String obj_key, String className){
        this.host = host;
        this.port = p;
        this.objkey = obj_key;
        this.className = className;
    }

    //create stub and return it 
    public Object createStub()
    {
        try{
            Class c = Class.forName(this.className + "Stub");
            Object o = c.newInstance();
            return o;
        }
        catch (Exception e){
            System.out.println(e);
            System.exit(1);
        }
        return null;
    }
}
