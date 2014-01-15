package rmi.messaging;
import rmi.ROR;
import java.io.Serializable;

public class RMIMessage implements Serializable
{
    public MessageType type;
    public String method;
    public Object returnObj;
       public Exception exception;
       public Object [] args;
       public Class [] argtypes;
       public ROR ror;
       public String key;

    //ping, duplicatekey, rornotfound, OK
    public RMIMessage(MessageType t){
        this.type = t;
    }
       //invoke a method
    public RMIMessage(MessageType t, String m, ROR r, Object [] arg, Class [] argtype){
        this.args = arg;
        this.type = t;    
        this.method = m;
        this.argtypes = argtype;
        this.ror = r;
    }

    //return the result
    public RMIMessage(MessageType t, Object o){
        this.type = t;
        this.returnObj = o;
    }

    //result of rorlookup
    public RMIMessage(MessageType t, ROR r){
        this.type = t;
        this.ror = r;
    }

    //send back an exception
    public RMIMessage(MessageType t, Exception e){
        this.type = t;
        this.exception = e;
    }

    //register a new ROR
    public RMIMessage(MessageType t, String k, ROR r){
        this.type = t;
        this.ror =r;
        this.key = k;
    }

    //lookup ROR
    public RMIMessage(MessageType t, String k){
        this.type = t;
        this.key = k;
    }
}
