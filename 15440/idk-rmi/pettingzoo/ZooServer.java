package pettingzoo;

import rmi.RMIServer;
import rmi.registry.RegistryClient;
import java.io.*;
import java.net.*;

public class ZooServer implements Runnable {

    String animal1;
    String animal2;
    int port;

    public ZooServer(String animal1, String animal2, int port){
        this.animal1 = animal1;
        this.animal2 = animal2;
        this.port = port;
    }
    public void run() {

        //instantiate rmi server
        try{
            RMIServer rmiserver = new RMIServer("localhost", port, "localhost", 6001);
            Thread t = new Thread(rmiserver);
            t.start();
            Dog d = new Dog();
            Cat c = new Cat();
            rmiserver.addObj(this.animal1, d, "pettingzoo.Dog");
            rmiserver.addObj(this.animal2, c, "pettingzoo.Cat");

        }
        catch (Exception e){
            System.out.println(e);
            System.exit(1);
        }

    }
}
