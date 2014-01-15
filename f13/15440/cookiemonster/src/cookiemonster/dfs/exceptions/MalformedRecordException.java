package cookiemonster.dfs.exceptions;

import cookiemonster.dfs.Record;

public class MalformedRecordException extends Exception {
	Record record;
	public MalformedRecordException(Record r, String line) {
    super(r.toString() + " line: \"" + line + "\"");
		this.record = r;
	}

}
