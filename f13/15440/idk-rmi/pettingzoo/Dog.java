package pettingzoo;

import rmi.RemoteMarker;
import java.io.Serializable;

public class Dog implements RemoteMarker, Animal, Serializable {

    public String feed(String food) {
        return new String("ruff ruff");
    }

    public Animal reproduce(){
        return new Dog();
    }

    public void poop() throws Exception{
        throw  new Exception("poop");
    }
}
