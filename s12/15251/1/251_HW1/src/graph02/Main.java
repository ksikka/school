package graph02;

import java.io.*;
import java.util.*;

import org.jgrapht.*;
import org.jgrapht.ext.*;
import org.jgrapht.graph.*;

public class Main {

	/**
	 * @param args
	 * @throws FileNotFoundException 
	 */
	public static void main(String[] args) throws FileNotFoundException {
		String message = "";
		HashMap hash = new HashMap(10000);
		SimpleGraph graph = new SimpleGraph(String.class);
		String line = "";
		Scanner scan = new Scanner(new FileInputStream("/Users/johncole/Dropbox/CMU Folder/15-251/hw1/problems/02.graph"));
    	try{
    		//FOR ROOMS
    		int count = 0;
    		scan.nextLine();
    		while(scan.hasNextLine() && count<10000){
    			line = scan.nextLine();
    			count++;
    			//split by spaces
    			String[] words = line.split(" ");
    			Room r;
    			//System.out.println(words[0]);
    			if(words.length > 2){
    				String[] colors = {words[2], words[3], words[4], words[5], words[6]};
    				r = new Room(Integer.parseInt(words[0]), words[1].charAt(0), colors);
    			}
    			else{
    				r = new Room(Integer.parseInt(words[0]), words[1].charAt(0));
    			}
    			hash.put(words[0], r);
    			graph.addVertex(r);
    		}
    		//FOR PASSAGEWAYS
    		count = 0;
    		scan.nextLine();
    		while(scan.hasNextLine() && count<84817){
    			line = scan.nextLine();
    			count++;
    			//split by spaces
    			String[] words = line.split(" ");
    			//create passageways
    			Passageway p = new Passageway(Integer.parseInt(words[0]), Integer.parseInt(words[1]), words[2]);
    			graph.addEdge(hash.get(words[0]), hash.get(words[1]), p);
    		}
    	}
    	finally{
    		scan.close();
    	}
    	//done initializing
    	Room vStart = (Room)hash.get("0");
    	int w = 0;
    	while(w < 5){
    		Room theNextOne = new Room(); //for safe-keeping
    		Passageway[] edges = (Passageway[]) graph.edgesOf(vStart).toArray(new Passageway[0]);
    		for(int i = 0; i<edges.length; i++){ 
    			System.out.println(edges[i].toString());
    		}
    		System.out.println("This vertex has an ID of " + vStart.id);
    		for(int i = 0; i<edges.length; i++){    			
    			System.out.print("Checking E: " + edges[i].ints[1] + " " +edges[i].color);
    			//as this iterates over edges, the if checks if it's the right edge to follow
    			if(vStart.colors[0].equals(edges[i].color)){
    				System.out.println(" found a match!");
    				//System.out.println(message);
    				int idWeWant;
        			if(edges[i].ints[0] == vStart.id)
        				idWeWant = edges[i].ints[1];
        			else
        				idWeWant = edges[i].ints[0];
        			System.out.println("The other vertex is " + idWeWant);
    				Room roomWeWant = (Room)hash.get(""+idWeWant);
    				//System.out.println(roomWeWant.id);
    				if(vStart.colors[1].equals(roomWeWant.colors[0])
    					&& vStart.colors[2].equals(roomWeWant.colors[1]) 
    						&& vStart.colors[3].equals(roomWeWant.colors[2])
    							&& vStart.colors[4].equals(roomWeWant.colors[3])){
    								theNextOne = roomWeWant;
    								System.out.print("YAYAYAYAYAY!!! :)");
    								message = message.concat(vStart.message + "");
    							}
    				else {
    					System.out.println("So the edge matched the color, but the other vertex wasn't the right one.");
    				}
    								
    			}
    			else
    				System.out.println(" Wrong edge. Trying the next one...");
    		
    			
    			/*int idWeWant;
    			if(edges[i].ints[0] == vStart.id)
    				idWeWant = edges[i].ints[1];
    			else
    				idWeWant = edges[i].ints[0];
    			Room roomWeWant = (Room)hash.get(""+idWeWant);*/
    		
    		}
    		w++;
    		vStart = theNextOne;
    	}
    	
    	
	}

}
