package cookiemonster.dfs;

import java.util.HashMap;
import java.io.Serializable;
import cookiemonster.ConfigSyntaxError;


public class FSNodeConfig implements Serializable {

    public long MAXSIZE;
    public String workingDir;

	public String REG_HOST;
	public Integer REG_PORT;

    public FSNodeConfig() throws ConfigSyntaxError {
    	this(null);
    }
	public FSNodeConfig(HashMap<String, String> configMap) throws ConfigSyntaxError {
		// DEFAULTS
		this.MAXSIZE = 1000000000L; // 1 GB
		this.workingDir = "/tmp/cookiemonster/";
		if (configMap == null)
			return;
		// USER SETTINGS
		if (configMap.containsKey("max_node_size"))
			this.MAXSIZE = Integer.parseInt(configMap.get("max_node_size"));
		if (configMap.containsKey("dfs_working_dir"))
			this.workingDir = configMap.get("dfs_working_dir");
			
		
		this.REG_HOST = configMap.get("registry_host");
		this.REG_PORT = Integer.parseInt(configMap.get("registry_port"));
		
		if ((this.REG_HOST == null) || (this.REG_PORT == null)) {
			throw new ConfigSyntaxError("Please add registry_host and registry_port to the config.");
		}
	}

}
