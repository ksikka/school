
import java.net.UnknownHostException;
import java.net.Socket;
import java.net.ServerSocket;
import java.net.InetAddress;

import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.ObjectStreamException;

import java.io.Serializable;
import java.io.IOException;


class PMServer implements Runnable {
    ServerSocket serverSocket; 
    int port;
    Master master;
    ProcessManager pm;

    public PMServer(int port, Master master) throws IOException {
        this.port = port;
        this.serverSocket = new ServerSocket(port);
        this.master = master;
        System.out.println("Listening on port " + this.serverSocket.getLocalPort());
    }

    public PMServer(int port, ProcessManager pm) throws IOException {
        this.port = port;
        this.serverSocket = new ServerSocket(port);
        this.pm = pm;
        System.out.println("Listening on port " + this.serverSocket.getLocalPort());
    }

    public void run() {
        Socket client = null;

        while (true) {
            try {
                client = this.serverSocket.accept();
            } catch (IOException e) {
                System.out.println("PM Accept failed");
                System.exit(1);
            }
            Message m = null;
            try {
                ObjectInputStream ois = new ObjectInputStream(client.getInputStream());
                m = (Message) ois.readObject();
            } catch (IOException e){
                System.out.println("Fail to parse message");
                System.exit(1);
            } catch (ClassNotFoundException e){
                System.out.println("Cls not found");
                System.exit(1);
            }

            parseMessage(m, client);
        }
    }

    public void parseMessage(Message m, Socket client){
            if (m.messageType.equals("runProcess")) {
                // run the process im sending you.
                this.pm.runProcess(m);
            } else if (m.messageType.equals("sendProcess")) {
                // send a process you're running to someone else
                MigratableProcess p = this.pm.localProcesses.get(m.pid);
                Thread t = this.pm.localThreads.get(m.pid);
                p.suspend();
                t.stop();
                try {
                    Message nm = new Message(p, m.pid);
                    this.sendMessage(nm, m.targetHostname, m.port);
                } catch (IOException e) {
                    System.out.println("Send process failed");
                    System.exit(1);
                }
            } else if (m.messageType.equals("register")) {
                // this message should only be received by the master
                // else this.nm will be null
                Node clientNode = new Node(client.getInetAddress(), m.port);
                this.master.nm.nodes.add(clientNode);
            }
    }

    public void sendMessage(Message m, String targetHostname, int port) throws IOException, UnknownHostException {
        Socket targetHost = new Socket(targetHostname, port);
        ObjectOutputStream oos = new ObjectOutputStream(targetHost.getOutputStream());
        oos.writeObject(m);
        targetHost.close();
    }
}

