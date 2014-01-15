package rmi.messaging;

public enum MessageType{

    // Stub - RMIServer
	INVOKEMETHOD, RETURN, EXCEPTION, // request methods

    // RegistryClient - Registry
    REGISTERROR, LOOKUPROR,          // request methods
    DUPLICATE_KEY, RORRESULT, RORNOTFOUND,     // response method

    PING, // General Response Message
    OK; // General Response Message
}
