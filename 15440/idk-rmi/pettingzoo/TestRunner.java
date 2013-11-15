package pettingzoo;

import rmi.registry.Registry;
import java.io.IOException;
/* Tests the idkrmi facility.
 *  Makes a Petting Zoo, calls the PettingClient to Feed the animals. And more.
 *
 *  1. Run an RMI Registry thread.
 *  2. Runs two ZooServers which each initialize with a few aniamls
 *  3. Runs a few PettingClients, which play with the animals.
 *
 *  */

public class TestRunner {

    public TestRunner() {
    }

    // makes life easier...
    public void print(String s) {
        System.out.println("[TestRunner] " + s);
    }

    public void run() throws InterruptedException {
        //start
        Registry registry = null;
        try{
            registry = new Registry(6001);
        }
        catch (IOException e){
            print("Yo.");
            System.exit(1);
        }

        Thread t = new Thread(registry);
        t.start();

        print("Waiting 1 sec for Registry to start.");
        Thread.sleep(1000);

        ZooServer zoo1 = new ZooServer("Fido", "Garfield", 8001);
        ZooServer zoo2 = new ZooServer("Bud", "Fluffy", 8002);
        Thread zoot1 = new Thread(zoo1);
        Thread zoot2 = new Thread(zoo2);
        zoot1.start();
        zoot2.start();

        print("Waiting 1 sec for RMI Servers to start.");
        Thread.sleep(1000);

        //pettingclients
        PettingClient pc1 = new PettingClient("Fido", "Garfield", 1);
        PettingClient pc2 = new PettingClient("Bud", "Fluffy", 2);

        print("Running PettingClient 1");
        Thread pc1t = new Thread(pc1);
        pc1t.start();
        print("Running PettingClient 2");
        Thread pc2t = new Thread(pc2);
        pc2t.start();

        pc1t.join();
        pc2t.join();

        print("PetClient ran. Thank you, come again!");
    }

    public static void main(String[] args) {
        TestRunner t = new TestRunner();
        try {
            t.run();
        } catch (InterruptedException e) {
            System.out.println("Interrupted :(");
            System.exit(1);
        }
        System.exit(0);
    }
}
