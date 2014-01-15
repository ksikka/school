
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.StringTokenizer;
import java.lang.Thread;
import java.util.Arrays;
import java.util.HashMap;

import java.net.InetAddress;

public class ProcessManager {
    HashMap<Integer, MigratableProcess> localProcesses;
    HashMap<Integer, Thread> localThreads;

    public ProcessManager() {
        this.localProcesses =  new HashMap<Integer, MigratableProcess>();
        this.localThreads =  new HashMap<Integer, Thread>();
    }


    public void runProcess(Message m) {
        /* Start a thread with p, add to running processes list */
        Thread t = new Thread(m.p);
        t.start();

        this.localProcesses.put(m.pid, m.p);
        this.localThreads.put(m.pid, t);

        System.out.println("Started new process.");
        System.out.println("Processes running on this node are:");

        String output = "";
        for (Integer key : this.localProcesses.keySet()) {
            output += "Process: " + this.localProcesses.get(key).toString() + " PID: " + key +" \n";
        }

        System.out.println(output);
        // provision process id, and set attr on p
        // add t or p to running threads/processes list
        // note - we need to keep track of t so we can join it later if it's done.
    }

    public void registerNode(String masterAddr, int port, PMServer pmserver){
        Message m = new Message();
        m.messageType = "register";
        m.port = pmserver.serverSocket.getLocalPort();
        try{
            pmserver.sendMessage(m, masterAddr, port); // register node with the master
        }
        catch (IOException e){
            System.out.println("Failed to register node with server!");
            System.exit(1);
        }
    }

    public static void main(String[] args) throws IOException {
        System.out.println("Welcome to the Migratable Process Manager!");

        boolean slave = false;
        int port = 0; // only matters in slave mode
        String masterAddr = "";
        if (args.length >= 2) {
            if (args[0].equals("-c")) {
                slave = true;
                masterAddr = args[1];
                if (args[2].equals("-p")) {
                    port = Integer.parseInt(args[3]);
                }
            }

        }

        if (slave) {
            ProcessManager PM = new ProcessManager();
            PMServer pmserver = new PMServer(0, PM);
            Thread serverthread = new Thread(pmserver);
            serverthread.start();

            PM.registerNode(masterAddr, port, pmserver);

            try {
                serverthread.join();
            } catch (InterruptedException e) {
                System.out.println("Interrupted");
                System.exit(1);
            }
        } 
        //Master code
        else { 
            NodeManager NM = new NodeManager();
            Master master = new Master(NM);
            PMServer masterserver = new PMServer(9090, master);
            master.server = masterserver;
            Thread serverthread = new Thread(masterserver);
            serverthread.start();
            master.interactive();
        }
    }

}
