package cookiemonster.dfs;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.FileReader;
import java.io.Serializable;

/* Acts somewhat as a file descriptor for a remote file.
 * Allows a client to read remotely. 
 * The source file may be remote, so we cache chunks. */
public class Record implements Serializable {
	public String name;
	public int recordIndex;
	public FSManager fman;

	public Record(String name, int recordIndex) {
		this.name = name;
		this.recordIndex = recordIndex;
	}
	
	public String toString() {
		return String.format("(%s, %d)", this.name, this.recordIndex); 
	}
	
	public int hashCode() {
		return this.toString().hashCode();
	}
	
	public boolean equals(Object obj) {
		Record r2 = (Record) obj;
		return this.toString().equals(r2.toString());
	}
}
