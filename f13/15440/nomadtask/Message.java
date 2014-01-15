
import java.io.Serializable;

public class Message implements Serializable {
    String messageType;
    // runProcess     <=>    run a process p
    // sendProcess    <=>    suspend p w pid and ship it to another node
    // register    <=>    register a node (master specific behavior)

    // this is for the message telling the node to run/resume a process
    MigratableProcess p;

    // this is for the message telling the node to wrap up and ship the process elsewhere
    int pid;
    String targetHostname;
    int port;

    // register message also uses int port above
    // int port;

    public static final long serialVersionUID = 42L;

    // run a process message
    public Message(MigratableProcess p, int pid) {
        this.messageType = "runProcess";
        this.p = p;
        this.pid = pid;
        this.targetHostname = null;
        this.port = 0;
    }

    // wrap up and ship the process elsewhere message
    public Message(int pid, String targetHostname, int port) {
        this.messageType = "sendProcess";
        this.p = null;
        this.pid = pid;
        this.targetHostname = targetHostname;
        this.port = port;
    }

    public Message(){

    }
}
