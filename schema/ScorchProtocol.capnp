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

		# Services
		services					@10	:List(ServiceDescriptor);
		serviceUpdate				@11	:List(ServiceUpdate);
		servicesSubscription		@12	:List(ServiceSubscription);
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

		# Services
		listServices				@10	:ListServices;
		servicesSubscription		@11	:List(ServiceSubscription);
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

# Services

struct ServiceDescriptor {
	id				@0	:Text;
	displayName		@1	:Text;
	adapterId		@2	:Text;
	subjects		@3	:ServiceSubjects;
	actions			@4	:List(ServiceAction);
}

struct ServiceSubjects {
	status		@0	:Bool;
}

struct ServiceAction {
	id			@0	:Text;
	displayName	@1	:Text;
}

struct ServiceStatus {
	state		@0	:ServiceState;
	health		@1	:ServiceHealth;
	summary		@2	:Text;
	timestamp	@3	:Int64;
	fields		@4	:List(StatusField);
}

enum ServiceState {
	unknown		@0;
	offline		@1;
	starting	@2;
	online		@3;
	stopping	@4;
}

enum ServiceHealth {
	unknown		@0;
	healthy		@1;
	degraded	@2;
	unhealthy	@3;
}

struct StatusField {
	label	@0	:Text;
	value	@1	:Text;
}

struct ListServices {
	union {
		all			@0	:Void;
		services	@1	:List(Text);
	}
}

struct ServiceUpdate {
	serviceId		@0	:Text;
	union {
		descriptor	@1	:ServiceDescriptor;
		status		@2	:ServiceStatus;
	}
}

struct ServiceSubscription {
	serviceId		@0	:Text;
	
	union {
		subscribe	@1	:Void;
		unsubscribe	@2	:Void;
	}

	subjects		@3	:ServiceSubjects;
}
