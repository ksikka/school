package cookiemonster.dfs;

import java.io.Serializable;

public class Replica implements Serializable {
	Record record;
	FSNode node;
	
	public Replica(Record record, FSNode node) {
		this.record = record;
		this.node = node;
	}
}

