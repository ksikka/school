package graph02;

import java.awt.*;

public class Room {
	
	int id;
	char message;
	String[] colors = new String[5];
	
	public Room(int i, char m, String[] c){
		id = i;
		message = m;
		colors = c;
	}
	public Room(int i, char m){
		id = i;
		message = m;
	}
	public Room() {
		// TODO Auto-generated constructor stub
	}
	
	

}
