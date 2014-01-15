package cookiemonster.dfs;

import java.util.HashMap;
import java.io.Serializable;
import cookiemonster.ConfigSyntaxError;

public class FSManagerConfig implements Serializable {
	
	public long RECORD_SIZE;
	public int REPLICATION_FACTOR;
	public int HEARTBEAT_PERIOD;
	public HashMap<String, String> originalMap;

	public String REG_HOST;
	public Integer REG_PORT;
	
	public FSManagerConfig() throws ConfigSyntaxError {
		this(null);
	}
	public FSManagerConfig(HashMap<String, String> configMap) throws ConfigSyntaxError {
		this.originalMap = configMap;
		// DEFAULTS
		this.RECORD_SIZE = 10000000L; // 10MB
		this.REPLICATION_FACTOR = 3;
		this.HEARTBEAT_PERIOD = 10; // seconds
		
		if (configMap == null)
			return;

		// USER SETTINGS
		if (configMap.containsKey("record_size"))
			this.RECORD_SIZE = Long.parseLong(configMap.get("record_size"));
		if (configMap.containsKey("replication_factor"))
			this.REPLICATION_FACTOR = Integer.parseInt(configMap.get("replication_factor"));
		if (configMap.containsKey("heartbeat_interval"))
			this.HEARTBEAT_PERIOD = Integer.parseInt(configMap.get("heartbeat_interval"));
		
		this.REG_HOST = configMap.get("registry_host");
		this.REG_PORT = Integer.parseInt(configMap.get("registry_port"));
		
		if ((this.REG_HOST == null) || (this.REG_PORT == null)) {
			throw new ConfigSyntaxError("Please add registry_host and registry_port to the config.");
		}
	}

}
