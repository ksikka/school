import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.StringTokenizer;
import java.lang.Thread;
import java.util.Arrays;

import java.net.UnknownHostException;
import java.net.Socket;
import java.net.ServerSocket;
import java.net.InetAddress;

import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.ObjectStreamException;
import java.io.Serializable;
import java.lang.reflect.Constructor;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;


/* gets user input and tells the node manager what to do */
public class Master {
    NodeManager nm;
    PMServer server;
    static String[] availableProcesses = {
      "GrepProcess",
      "SleepProcess",
      "FileCopy",
      "SiteCrawl"
    };

    static String USAGE = "This is the help string.";

    public Master(NodeManager nm){
        this.nm = nm;
    }

    public String ps(String[] args) {
        String output = "Running processes:\n";

        //iterate through HashMap values iterator
        for (Integer key : this.nm.processes.keySet()) {
            output += "Process: " + this.nm.processes.get(key).toString() + " PID: " + key +" \n";
        }

        return output;
    }
    public void interactive() {
        /* Starts an interactive REPL,
         *   writing output to STDOUT
         *   and reading input from STDIN */
        String input = "help";
        String output;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        do {
            // eval
            output = this.eval(input);
            System.out.println(output);
            System.out.print(">>> ");
            // read next command
            try {
                input=br.readLine();
            } catch(IOException io) {
                io.printStackTrace();
                System.out.print(">>> ");
            }
        } while(input != null);
    }


    public String eval(String[] command) {
        /* Given a command,
         *   evaluates it using this ProcessManager's methods.
         *   Returns an output string to be presented to the user. */

        if (command.length == 0)
            return USAGE;

        String cmd = command[0];
        for (int j= 0; j< command.length; j++){
            System.out.println("'" + command[j] + "'");
        }



        if (cmd.equals("help"))
            return USAGE;

        // first argument is from slave #
        // second argument is to slave #
        // third argument is pid of process to send
        if (cmd.equals("SendProcess")){
        
            Node fromNode = this.nm.nodes.get(Integer.parseInt(command[1])); 
            Node toNode = this.nm.nodes.get(Integer.parseInt(command[2])); 

            String fromHostname = fromNode.addr.getHostAddress();
            String toHostname = toNode.addr.getHostAddress();
            int fromPort = fromNode.port;
            int toPort = toNode.port;
            int pid = Integer.parseInt(command[3]);

            Message m = new Message(pid, toHostname, toPort);  
            try{
                this.server.sendMessage(m, fromHostname, fromPort);
                return "Process was sent.";
            }   
            catch (IOException e){
                System.out.println(e);
                return "MigratableProcess failed with error:\n" + e;
            }

        }

        if (cmd.equals("ps"))
            return this.ps(command);

        // list of known migratable process
        // search the list
        // if found, run and add to running processes list

        for(int i = 0; i < Master.availableProcesses.length; i++) {
            if (cmd.equals(Master.availableProcesses[i])) {

                MigratableProcess p;

                try {
                    Class<?> process = Class.forName(cmd);
                    Class[] args = new Class[1];
                    args[0] = String[].class;
                    Constructor<?> ctor = process.getConstructor(args);
                    p = (MigratableProcess) ctor.newInstance((Object)Arrays.copyOfRange(command, 1, command.length));

                    if (! (p == null)){
                        Message m = new Message(p, this.nm.iterator);
                        Node slave = this.nm.nodes.get(this.nm.iterator % this.nm.nodes.size());
                        this.nm.processes.put(this.nm.iterator, p);
                        this.nm.iterator++;
                        this.server.sendMessage(m, slave.addr.getHostAddress(), slave.port);
                        return "Process started on a slave."; 
                    } else  return "Command not recognized. " + USAGE;

                } catch (Exception e) {
                    System.out.println(e);
                    return "MigratableProcess failed with error:\n" + e;
                }

            }
        }

        return "Command not recognized. " + USAGE;
    }

    public String eval(String raw_command) {
        StringTokenizer st = new StringTokenizer(raw_command);
        ArrayList<String> commandList = new ArrayList<String>();
        while (st.hasMoreTokens()) {
            commandList.add(st.nextToken());
        }
        String[] commandArr = new String[commandList.size()];
        commandList.toArray(commandArr);
        return this.eval(commandArr);
    }

}
