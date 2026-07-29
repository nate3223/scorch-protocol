@0x807b51725243a5e3;

using Cxx = import "/capnp/c++.capnp";
$Cxx.namespace("scorch::protocol");

struct AgentMessage {
	# Correlation IDs are zero when unused during sequential initialization.
	messageId	@0	:UInt64;
	replyTo		@1	:UInt64;

	union {
		error						@2	:ProtocolError;

		# Existing registrations
		authenticationInitiation	@3	:AuthenticationInitiation;
		authenticationRequest		@4	:AuthenticationRequest;

		# New registrations
		pair						@5	:PairRequest;
		pairingConfirmation			@6	:PairingConfirmation;

		# Connected
		heartbeat					@7	:Heartbeat;
		command						@8	:CommandResponse;
		shareConfirmation			@9	:ShareConfirmation;
	}
}

struct ServerMessage {
	# Correlation IDs are zero when unused during sequential initialization.
	messageId	@0	:UInt64;
	replyTo		@1	:UInt64;

	union {
		error						@2	:ProtocolError;

		# Existing registrations
		authenticationInitiation	@3	:AuthenticationInitiationResponse;
		authenticationResult		@4	:AuthenticationResult;

		# New registrations
		pairCode					@5	:PairCodeResult;
		pairingResult				@6	:PairingResult;

		# Connected
		heartbeat					@7	:Heartbeat;
		command						@8	:CommandRequest;
		shareRequest				@9	:ShareRequest;
	}
}

struct ProtocolError {
	message	@0	:Text;
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

struct ShareRequest {
	info	@0	:Text;
}

struct ShareConfirmation {
	union {
		approved	@0	:Void;
		rejected	@1	:Void;
	}
}

struct Heartbeat {
	timestamp	@0	:UInt64;
}

struct CommandRequest {
	timestamp	@0	:UInt64;

	union {
		http		@1	:HttpCommand;
		reserved	@2	:Void;
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
	timestamp	@0	:UInt64;

	union {
		success			@1	:Void;
		error			@2	:Text;
		httpResponse	@3	:HttpResponse;
	}
}

struct HttpResponse {
	statusCode	@0	:UInt32;
	headers		@1	:List(Header);
	body		@2	:Data;
}
