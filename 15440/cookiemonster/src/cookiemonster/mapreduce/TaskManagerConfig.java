package cookiemonster.mapreduce;

import java.util.HashMap;
import cookiemonster.ConfigSyntaxError;
import java.io.Serializable;


public class TaskManagerConfig implements Serializable {

	public int NUM_MAP_SLOTS;
	public int NUM_REDUCE_SLOTS;

	public String REG_HOST;
	public Integer REG_PORT;
	
	public HashMap<String, String> originalMap;

	public TaskManagerConfig() throws ConfigSyntaxError {
		this(null);
	}
	
	public TaskManagerConfig(HashMap<String, String> configMap) throws ConfigSyntaxError {
		this.originalMap = configMap;
		// DEFAULTS
		this.NUM_MAP_SLOTS = 4;
		this.NUM_REDUCE_SLOTS = 3;

		
		if (configMap == null) {
			return;
		}

	    // USER SETTINGS
		if (configMap.containsKey("map_slots"))
			this.NUM_MAP_SLOTS = Integer.parseInt(configMap.get("map_slots"));
		if (configMap.containsKey("reduce_slots"))
			this.NUM_REDUCE_SLOTS = Integer.parseInt(configMap.get("reduce_slots"));
	
		this.REG_HOST = configMap.get("registry_host");
		this.REG_PORT = Integer.parseInt(configMap.get("registry_port"));
		
		if ((this.REG_HOST == null) || (this.REG_PORT == null)) {
			throw new ConfigSyntaxError("Please add registry_host and registry_port to the config.");
		}
	}

}
