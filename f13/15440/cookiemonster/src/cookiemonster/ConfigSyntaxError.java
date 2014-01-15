package cookiemonster;

public class ConfigSyntaxError extends Exception {
	public String message;
	public ConfigSyntaxError() {
		this.message = "There was an error parsing the Config file. Please check the syntax. It should be \"<word> <value>\"";
	}
	public ConfigSyntaxError(String s) {
		this.message = s;
	}
}
