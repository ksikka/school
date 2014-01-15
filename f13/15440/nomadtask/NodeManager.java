
import java.util.ArrayList;
import java.net.InetAddress;
import java.util.HashMap;


public class NodeManager {
    ArrayList<Node> nodes;
    HashMap<Integer, MigratableProcess> processes;
    int iterator;
    
    public NodeManager() {
        this.nodes = new ArrayList<Node>();
        this.processes = new HashMap<Integer, MigratableProcess>();
        this.iterator = 0;
    }
}

class Node {
    public InetAddress addr;
    public int port;
    public Node(InetAddress addr, int port) {
        this.addr = addr;
        this.port = port;
    }
}
