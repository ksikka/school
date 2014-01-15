package cookiemonster.mapreduce;

import java.util.ArrayList;
import java.io.Serializable;
import java.util.Map.Entry;

public abstract class Mapper implements Serializable {

   private static final long serialVersionUID = 6529685098267757690L;
	 abstract public ArrayList<Entry<String, String>> map(String key, String value);

}
