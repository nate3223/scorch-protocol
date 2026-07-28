@0x807b51725243a5e3;

using Cxx = import "/capnp/c++.capnp";
$Cxx.namespace("scorch::protocol");

struct AgentMessage {
	union {
		# Existing registrations
		authenticationInitiation	@0	:AuthenticationInitiation;
		authenticationRequest		@1	:AuthenticationRequest;

		# New registrations
		pair						@2	:PairRequest;
		pairingConfirmation			@3	:PairingConfirmation;

		# Connected
		heartbeat					@4	:HeartbeatRequest;
		command						@5	:CommandResponse;
	}
}

struct ServerMessage {
	union {
		# Existing registrations
		authenticationInitiation	@0	:AuthenticationInitiationResponse;
		authenticationResult		@1	:AuthenticationResult;

		# New registrations
		pairCode					@2	:PairCodeResult;
		pairingResult				@3	:PairingResult;

		# Connected
		heartbeat					@4	:HeartbeatResponse;
		command						@5	:CommandRequest;
	}
}

#  Existing registrations
#  Agent                                      Server
#    |                                          |
#    |---- TCP/TLS connection ----------------->|
#    |---- AuthenticationInitiation ----------->|
#    |                                          |
#    |<----- AuthenticationInitiationResponse --|
#    |                                          |
#    |---- AuthenticationRequest -------------->|
#    |                                          |
#    |       <Server verifies signature>        |
#    |                                          |
#    |<------------- AuthenticationResult ------|
#    |                                          |

struct AuthenticationInitiation {
	uuid	@0	:Text;
}

struct AuthenticationInitiationResponse {
	union {
		challenge	@0	:AuthenticationChallenge;
		invalidUuid	@1	:Void;
		retry		@2	:Void;
	}
}

struct AuthenticationChallenge {
	challenge	@0	:Data;
}

struct AuthenticationRequest {
	signature	@0	:Data;
}

struct AuthenticationResult {
	union {
		success			@0	:Void;
		challengeFailed	@1	:Void;
	}
}

#  New Registrations
#  Agent                                      Server
#    |                                            |
#    |----- TCP/TLS connection ------------------>|
#    |----- PairRequest ------------------------->|
#    |                                            |
#    |<--------------------- PairCodeResult ------|
#    |                                            |
#    |    <User enters PairCode in Discord>       |
#    |                                            |
#    |<-------------------- PairingResult --------|
#    |                                            |
#    |----- PairingConfirmation ----------------->|
#    |                                            |
#    |----- AuthenticationInitiation ------------>|
#    |<Agent connects as an exsiting registration>|
#    |                                            |

struct PairRequest {
	uuid		@0	:Text;
	publicKey	@1	:Data;
}

struct PairCodeResult {
	union {
		valid	@0	:PairCode;
		invalid	@1	:Void;
		retry	@2	:Void;
	}
}

struct PairCode {
	code	@0	:Text;
}

struct PairingResult {
	union {
		success		@0	:PairingSuccess;
		timedOut	@1	:Void;
	}
}

struct PairingSuccess {
	pairingInfo	@0	:Text;
}

struct PairingConfirmation {
	union {
		approved	@0	:Void;
		rejected	@1	:Void;
	}
}

# Connected

struct HeartbeatRequest {
	timestamp	@0	:UInt64;
}

struct HeartbeatResponse {
	timestamp	@0	:UInt64;
}

struct CommandRequest {
	id			@0	:UInt64;
	timestamp	@1	:UInt64;

	union {
		http		@2	:HttpCommand;
		reserved	@3	:Void;
	}
}

struct HttpCommand {
	url		@0	:Text;
	method	@1	:Text;
	headers	@2	:List(Header);
	body	@3	:Data;
}

struct Header {
	name	@0	:Text;
	value	@1	:Text;
}

struct CommandResponse {
	id			@0	:UInt64;
	timestamp	@1	:UInt64;

	union {
		success			@2	:Void;
		error			@3	:Text;
		httpResponse	@4	:HttpResponse;
	}
}

struct HttpResponse {
	statusCode	@0	:UInt32;
	headers		@1	:List(Header);
	body		@2	:Data;
}
