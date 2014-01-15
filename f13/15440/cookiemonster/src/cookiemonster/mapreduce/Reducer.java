package cookiemonster.mapreduce;

import java.util.ArrayList;
import java.io.Serializable;

public abstract class Reducer implements Serializable {

   private static final long serialVersionUID = 6526775769096850982L;
	abstract public String reduce(String key, ArrayList<String> value);
}
