package pettingzoo;

import rmi.registry.RegistryClient;
import rmi.Stub;
import java.net.UnknownHostException;
import java.io.IOException;

public class PettingClient implements Runnable {

    String animal1;
    String animal2;
    int clientnum;

    public PettingClient(String animal1, String animal2, int clientnum){
        this.animal1 = animal1;
        this.animal2 = animal2;
        this.clientnum = clientnum;
    }

    public void printClient(String m){
        System.out.println("[PettingClient " + this.clientnum + "] " + m);
    }

    public void run() {

        try{
            RegistryClient rc = new RegistryClient("localhost", 6001);
            DogStub stub1 = (DogStub)rc.lookupStub(animal1);
            CatStub stub2 = (CatStub)rc.lookupStub(animal2);

            printClient("Petting animals.");
            String sound1 = stub1.feed("Dogfood");
            printClient(sound1);

            Dog puppy = (Dog)stub1.reproduce();

            String sound2 = stub2.feed("Catfood");
            printClient(sound2);

            String sound3 = puppy.feed("Dogfood");
            printClient(sound3);

            printClient("Animals are throwing poop exceptions!");
            printClient("Testing if exceptions work.");
            try{
                stub1.poop();
            }
            catch (Exception e){
                System.out.println("[PettingClient " + this.clientnum + "] Successfully caught exception (" +e+ ")");
            }
        }
        catch (Exception e){
            System.out.println(e);
            System.exit(1);
        }

 
    }

}
