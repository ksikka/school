package pettingzoo;

public interface Animal {

    public String feed(String food);

    public Animal reproduce();

    public void poop() throws Exception;
}
