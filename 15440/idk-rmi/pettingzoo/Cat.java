package pettingzoo;

import rmi.RemoteMarker;
import java.io.*;

public class Cat implements RemoteMarker, Animal, Serializable {

    public String feed(String food) {
        return new String("meow");
    }

    public Animal reproduce(){
        return new Cat();
    }

    public void poop() throws Exception{
        throw  new Exception("poop");
    }
}
