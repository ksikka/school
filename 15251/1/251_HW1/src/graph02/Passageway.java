package graph02;

public class Passageway {
	
	String color;
	int[] ints = new int[3];
	
	public Passageway(int x, int y, String c){
		color = c;
		ints[0] = x;
		ints[1] = y;
		ints[2] = x;
	}

	public Passageway() {
		
	}
	
	public String toString(){
		return ints[0] + " " + ints[1] + " " + color;
		
	}
}
