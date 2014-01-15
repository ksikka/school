package rmi;

public class RMIException extends Exception{

    Exception e;
    public RMIException(Exception e){
        super();
        this.e = e;
    }
}
