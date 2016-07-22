/// The MQTT Agent is always started by a <class>Net.MQTT.Client</class> in the background to manage the real communication with the broker.
/// <p>The agent inherits its settings from the Client, which started it and it is responsible for:<ul>
/// <li>Building the TCP connection to the broker.</li>
/// <li>Executing the tasks created by the Client (and the Agent itself) based on the <class>Net.MQTT.Aux.TaskList</class> records.
///  E.g.: sending various messages to the broker.</li>
/// <li>Keeping the connection alive by sending PING requests to the broker, when no other messages has been sent for a certain amount of time.</li>
/// <li>Listening for incoming messages from the broker and triggering appropriate actions based on the message type.</li>
/// </ul></p>
Class Net.MQTT.Agent Extends Net.MQTT.Client
{

Property connected As %Boolean [ InitialExpression = 0 ];

Property device As %String;

Property saveIODev As %String;

Property transTable As %String [ InitialExpression = {##class(%IO.I.TranslationDevice).GetCharEncodingTable("UTF-8")} ];

Property lastMessage As %TimeStamp [ InitialExpression = {$ZDateTime($ZTimeStamp, 3, 1)} ];

Property lastPing As %TimeStamp;

Property fatalError As %Boolean [ InitialExpression = 0 ];

/// This method is called directly (as a background job) by the <class>Net.MQTT.Client</class> to start the Agent.
/// <p><var>pInitialState</var> is the XML serialized content of the calling Client object, from which the agent can populate its own properties.</p>
/// <p><var>pUsername</var> and <var>pPassword</var> are the optional credentials to be sent to the broker on connecting.</p>
/// <p>The Agent builds the TCP connection to the broker, sends a <b><var>CONNECT</var></b> message and then starts to communicate with the broker.</p>
ClassMethod StartListening(pInitialState As %String, pUsername As %String = "", pPassword As %String = "")
{
	Set ret = ""
	Set reader = ##class(%XML.Reader).%New()
	Do reader.Correlate("root", ..%ClassName(1))
	Set tSC = reader.OpenString(pInitialState)
	If $$$ISOK(tSC) && reader.Next(.agent) {
		Set tSC = agent.DoCONNECT(pUsername, pPassword)
		If $$$ISOK(tSC) {
			Do agent.Listen()
		}
		Else {
			Set ret = $System.Status.GetErrorText(tSC)
		}
	}
	Else {
		Set ret = "MQTT Agent cannot start (missing initial state)"
	}
}

/// The main function of the Agent. Unless a fatal error happens, it runs in an endless loop, doing onw of the followin things in every loop:<ul>
/// <li>If a pending <class>Net.MQTT.Aux.TaskList</class> object can be found for the Agent's unique <property>connectionId</property>,
///  it starts to execute the corresponding task, then signals the initiator of the task via the <class>%SYSTEM.Event</class> API.</li>
/// <li>If no response has arrived from the broker for the last PING request within the <property>KeepAliveInterval</property>
///  it treats the connection to the broker broken and stops.</li>
/// <li>If no other messages has been sent to the broker for a certain amount of time (~ 80% of the ) <property>KeepAliveInterval</property>,
///  it sends a PING request to keep the connection alive.</li>
/// <li>Listens for incoming messages.</li>
/// </ul>
Method Listen() [ Internal, Private ]
{
	Use ..device
	$$$MQTTTraceINF("Agent for " _ ..ClientId _ " to <" _ ..Host _ ":" _ ..Port _ "> starts listening")
	Do SetIO^%NLS("RAW")
	While 1 {
		If ..fatalError {
			Quit
		}
		
		TRY {
			Set tSC = ##class(Net.MQTT.Aux.TaskList).AcquireNext(..connectionId, .taskId, .contextId, .action)
			If $$$ISOK(tSC) {
				If taskId '= "" {
					$$$MQTTTraceINF("Agent for " _ ..ClientId _ " to <" _ ..Host _ ":" _ ..Port _ "> processes task (" _taskId _ ")")
					Set tSC = $METHOD($this, "Do" _ action, taskId, contextId)
					Set tSC = ##class(Net.MQTT.Aux.TaskList).SignalTask(..connectionId, taskId, tSC, (''..debugMode))
				}
				ElseIf (..lastPing '= "") && ($System.SQL.DATEDIFF("s", ..lastPing, $ZDateTime($ZTimeStamp, 3, 1)) > ..KeepAliveInterval) {
					$$$MQTTTraceERR("PINGRESP message has not arrived from <" _ ..Host _ ":" _ ..Port _ "> within the timeout interval")
					Set ..fatalError = 1
				}
				ElseIf $System.SQL.DATEDIFF("s", ..lastMessage, $ZDateTime($ZTimeStamp, 3, 1)) > (..KeepAliveInterval * .8) {
					$$$MQTTTraceINF("Agent for " _ ..ClientId _ " to <" _ ..Host _ ":" _ ..Port _ "> sends ping")
					Set tSC = ..SendPINGREQ()
					If $$$ISERR(tSC) {
						$$$MQTTTraceERR("PINGREQ message cannot be sent to <" _ ..Host _ ":" _ ..Port _ ">")
						Set ..fatalError = 1
					}
				}
				Else {
					Set tSC = ..RecvMessage()
				}
			}
		}
		CATCH ex {
			Set tSC = ex.AsStatus()
		}
		
		If $$$ISERR(tSC) {
			$$$MQTTTraceERR($System.Status.GetErrorText(tSC))
		}
	}
	
	Do ..CloseDev()
	Use ..saveIODev
	
	Quit
}

/// Listens for incoming messages.
/// <p>First takes a 1 byte MQTT Header. The takes the following 1 to 4 bytes to define the remaining length of the message.
///  Finally reads the remaining part of the message and triggers appropriate action based on the message type (extracted from the Header).</p>
Method RecvMessage() As %Status
{
 Set tSC = $$$OK
 TRY {	
	Read header#1:0 Set timeout = ('$Test)
	If 'timeout {
		$$$MQTTTraceIN("Header", header)
		Set type	= ..GetMessageType(header)
		Set typeT	= $$$MQTTMsgType(type)
		Set dup		= ..IsDuplicate(header)
		Set qos		= ..GetQoSLevel(header)
		Set retain	= ..IsRetain(header)
		
		Set multi = 1, length = 0, pos = 2, rl = ""
		For i = 1: 1: 4 {
			Read next#1:..ReadTimeout Set timeout = ('$Test)
			If timeout {
				Set tSC = $$$ERROR($$$GeneralError, "Invalid " _ typeT _ " message has arrived from <" _ ..Host _ ":" _ ..Port _ "> (missing Remaining Length)")
				Quit
			}
			Set rl = rl _ next
			Set next = $Ascii(next)
			Set length = length + ((next # 128) * multi)
			If next < 128 { Quit }
			Set multi = multi * 128
		}
		
		Set content = ""
		$$$MQTTTraceIN("Length", rl)
		If $$$ISOK(tSC) && (length > 0) {
			Read content#length:..ReadTimeout Set timeout = ('$Test)
			If timeout || ($Length(content) '= length) {
				Set tSC = $$$ERROR($$$GeneralError, "Invalid " _ typeT _ " message has arrived from <" _ ..Host _ ":" _ ..Port _ "> (missing content)")
			}
		}
		If $$$ISOK(tSC) {
			$$$MQTTTraceIN(typeT, header _ rl _ content)
		}
		Set tSC = $METHOD($this, "Recv" _ typeT, dup, qos, retain, content)
	}
 }
 CATCH ex {
	If ex.%IsA("%Exception.SystemException") && (ex.Name = "<READ>") {
		$$$MQTTTraceERR("MQTT broker probably closed TCP connection to <" _ ..Host _ ":" _ ..Port _ "> (READ error)")
		Set ..fatalError = 1
	}
	Set tSC = ex.AsStatus() 
 } 
 Quit tSC
}

/// Builds the TCP connection to the MQTT broker and sends the <b><var>CONNECT</var></b> message.
Method DoCONNECT(pUsername As %String = "", pPassword As %String = "") As %Status [ Internal, Private ]
{
	Set tSC = $$$OK
	$$$MQTTTraceINF("Agent for " _ ..ClientId _ " to <" _ ..Host _ ":" _ ..Port _ "> is starting")
	
	Set ..saveIODev = $IO
	If ('..connected) {
		Set ..device = "|TCP|" _ ..Port _ "|" _ $P($Job, ":")
		Open ..device:(..Host:..Port::::::):..ConnectTimeout Set timeout=('$Test)
		
		If timeout {
			$$$MQTTTraceERR("Agent for " _ ..ClientId _ " to <" _ ..Host _ ":" _ ..Port _ "> failed to start TCP connection")
			Quit $$$ERROR($$$GeneralError, "TCP Connection to <" _ ..Host _ ":" _ ..Port _ "> has not succeeded within the timeout interval")
		}
		Else {
			$$$MQTTTraceINF("Agent for " _ ..ClientId _ " to <" _ ..Host _ ":" _ ..Port _ "> started TCP connection")
			Set ..connected = 1
		}
	}
	
	Use ..device
	Do SetIO^%NLS("RAW")
	Set tSC = ..SendCONNECT(pUsername, pPassword)
	If $$$ISERR(tSC) {
		Do ..CloseDev()
	} 
	Use ..saveIODev
	
	Quit tSC
}

/// Sends a <b><var>DISCONNECT</var></b> message to the MQTT broker and closes the TCP connection.
Method DoDISCONNECT(pTaskId As %String, pConnectionId As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..SendDISCONNECT()
	Do ..CloseDev()
	Use ..saveIODev
	
	Quit tSC
}

/// Sends a <b><var>SUBSCRIBE</var></b> message to the MQTT broker. 
/// <p>The <property>ContextId</property> of the corresponding <class>Net.MQTT.Aux.TaskList</class> object is a Message Idenifier.
/// If it contains a colon, this is a repeated attempt, because no acknowledge has been received from the broker within the defined timout period.</p>
/// <p>The details of the <b><var>SUBSCRIBE</var></b> message must be stored in a <class>Net.MQTT.Aux.Subscription</class> object.</p>
Method DoSUBSCRIBE(pTaskId As %String, pMessageId As %String) As %Status [ Internal, Private ]
{
	Set dup = 0
	Set msgid = pMessageId
	If $Length(pMessageId, ":") > 1 {
		Set msgid = $Piece(pMessageId, ":", 1)
		Set dup = (''$Piece(pMessageId, ":", 2))
	}
	Set topics = ##class(Net.MQTT.Aux.Subscription).GetTopicList(..ClientId, msgid, .tSC)
	Set:$$$ISOK(tSC) tSC = ..SendSUBSCRIBE(msgid, topics, dup)
	
	Quit tSC
}

/// Sends a <b><var>UNSUBSCRIBE</var></b> message to the MQTT broker. 
/// <p>The <property>ContextId</property> of the corresponding <class>Net.MQTT.Aux.TaskList</class> object is a Message Idenifier.
/// If it contains a colon, this is a repeated attempt, because no acknowledge has been received from the broker within the defined timout period.</p>
/// <p>The details of the <b><var>UNSUBSCRIBE</var></b> message must be stored in a <class>Net.MQTT.Aux.Subscription</class> object.</p>
Method DoUNSUBSCRIBE(pTaskId As %String, pMessageId As %String) As %Status [ Internal, Private ]
{
	Set dup = 0
	Set msgid = pMessageId
	If $Length(pMessageId, ":") > 1 {
		Set msgid = $Piece(pMessageId, ":", 1)
		Set dup = (''$Piece(pMessageId, ":", 2))
	}
	Set topics = ##class(Net.MQTT.Aux.Subscription).GetTopicList(..ClientId, msgid, .tSC)
	Set:$$$ISOK(tSC) tSC = ..SendUNSUBSCRIBE(msgid, topics, dup)
	
	Quit tSC
}

/// Sends a <b><var>PUBLISH</var></b> message to the MQTT broker. 
/// <p>The <property>ContextId</property> of the corresponding <class>Net.MQTT.Aux.TaskList</class> object is a <class>Net.MQTT.Aux.MessageStore</class> object ID.
/// If it contains a colon, this is a repeated attempt, because no acknowledge has been received from the broker within the defined timout period.</p>
/// <p>The details of the <b><var>PUBLISH</var></b> message are stored in the referenced <class>Net.MQTT.Aux.MessageStore</class> object.</p>
/// <p>On QoS levels &gt; 0 it also pushes the <class>Net.MQTT.Aux.MessageStatus</class> to the next state 
///  (either waiting for a <b><var>PUBACK</var></b> or <b><var>PUBREC</var></b> message).</p>
Method DoPUBLISH(pTaskId As %String, pMessageStoreId As %String) As %Status [ Internal, Private ]
{
	Set dup = 0
	Set msgid = pMessageStoreId
	If $Length(pMessageStoreId, ":") > 1 {
		Set msgid = $Piece(pMessageStoreId, ":", 1)
		Set dup = (''$Piece(pMessageStoreId, ":", 2))
	}
	Set message = ##class(Net.MQTT.MessageStore).%OpenId(msgid, -1, .tSC)
	Set:$$$ISOK(tSC) tSC = ..SendPUBLISH(message, dup)
	If $$$ISOK(tSC) {
		If message.QoSLevel = 1 {
			Set tSC = ##class(Net.MQTT.Aux.MessageStatus).AcknowledgeMessageOut(..ClientId, message.MessageId)
		}
		ElseIf message.QoSLevel = 2 {
			Set tSC = ##class(Net.MQTT.Aux.MessageStatus).ReceiveMessageOut(..ClientId, message.MessageId)
		}
	}
	
	Quit tSC
}

/// Sends a <b><var>PUBACK</var></b> message to the MQTT broker for an incoming, QoS Level 1 message. 
/// <p>The <property>ContextId</property> of the corresponding <class>Net.MQTT.Aux.TaskList</class> object is a Message Identifier.</p>
/// <p>This is the end of the message flow of the incoming message.</p>
Method DoPUBACK(pTaskId As %String, pMessageId As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..SendPUBACK(pMessageId)
	Set:$$$ISOK(tSC) tSC = ##class(Net.MQTT.Aux.MessageStatus).DoneMessageIn(..ClientId, pMessageId)
	
	Quit tSC
}

/// Sends a <b><var>PUBREC</var></b> message to the MQTT broker for an incoming, QoS Level 2 message. 
/// <p>The <property>ContextId</property> of the corresponding <class>Net.MQTT.Aux.TaskList</class> object is a Message Identifier.</p>
/// <p>It also pushes the <class>Net.MQTT.Aux.MessageStatus</class> to the next state (waiting for a <b><var>PUBREL</var></b> message).</p>
Method DoPUBREC(pTaskId As %String, pMessageId As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..SendPUBREC(pMessageId)
	Set:$$$ISOK(tSC) tSC = ##class(Net.MQTT.Aux.MessageStatus).ReleaseMessageIn(..ClientId, pMessageId)
	
	Quit tSC
}

/// Sends a <b><var>PUBREL</var></b> message to the MQTT broker for an outgoing, QoS Level 2 message. 
/// <p>The <property>ContextId</property> of the corresponding <class>Net.MQTT.Aux.TaskList</class> object is a Message Identifier.
///  If it contains a colon, this is a repeated attempt, because no acknowledge has been received for the original <b><var>PUBLISH</var></b> message
///  from the broker within the defined timout period.</p>
/// <p>It also pushes the <class>Net.MQTT.Aux.MessageStatus</class> to the next state (waiting for a <b><var>PUBCOMP</var></b> message).</p>
Method DoPUBREL(pTaskId As %String, pMessageId As %String) As %Status [ Internal, Private ]
{
	Set dup = 0
	Set msgid = pMessageId
	If $Length(pMessageId, ":") > 1 {
		Set msgid = $Piece(pMessageId, ":", 1)
		Set dup = (''$Piece(pMessageId, ":", 2))
	}
	Set tSC = ..SendPUBREL(msgid, dup)
	Set:$$$ISOK(tSC) tSC = ##class(Net.MQTT.Aux.MessageStatus).CompleteMessageOut(..ClientId, pMessageId)
	
	Quit tSC
}

/// Sends a <b><var>PUBCOMP</var></b> message to the MQTT broker for an incoming, QoS Level 2 message. 
/// <p>The <property>ContextId</property> of the corresponding <class>Net.MQTT.Aux.TaskList</class> object is a Message Identifier.</p>
/// <p>This is the end of the message flow of the incoming message.</p>
Method DoPUBCOMP(pTaskId As %String, pMessageId As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..SendPUBCOMP(pMessageId)
	Set:$$$ISOK(tSC) tSC = ##class(Net.MQTT.Aux.MessageStatus).DoneMessageIn(..ClientId, pMessageId)
	
	Quit tSC
}

/// Creates the variable header and payload of a <b><var>CONNECT</var></b> message and sends the package to the MQTT broker.
Method SendCONNECT(pUsername As %String = "", pPassword As %String = "") As %Status [ Internal, Private ]
{
	If pUsername = "" {
		Set pPassword = ""
	}
	Set will = ($IsObject(..LastWill) && (..LastWill.Topic '= "") && (..LastWill.Content '= ""))
	
	Set varhdr = $Char($Select(..CleanSession: $$$MQTTCleanSession, 1: 0)
		+ $Select(will: $$$MQTTWillFlag, 1: 0)
		+ $Select((will && ..LastWill.QoSLevel = 1): $$$MQTTWillQoS1, (will && ..LastWill.QoSLevel = 2): $$$MQTTWillQoS2, 1: 0)
		+ $Select((will && ..LastWill.Retain): $$$MQTTWillRetain, 1: 0)
		+ $Select(pUsername '= "": $$$MQTTUsernameFlag, 1: 0)
		+ $Select(pPassword '= "": $$$MQTTPasswordFlag, 1: 0)
	)
	
	Set varhdr	= ..GetProtocolName() _ ..GetProtocolVersion() _ varhdr _ $$$MQTTEncodeNumber(..KeepAliveInterval)
	Set payload	= ..GetUTFString(..ClientId)
	If will {
		Set payload = payload _ ..GetUTFString(..LastWill.Topic) _ ..GetUTFString(..LastWill.Content)
	}
	If pUsername '= "" {
		Set payload = payload _ ..GetUTFString(pUsername)
		If pPassword '= "" {
			Set payload = payload _ ..GetUTFString(pPassword)
		}
	}
	
	Quit ..PackSendMsg(varhdr_payload, $$$MQTTCONNECT)
}

/// Creates a <b><var>DISCONNECT</var></b> message and sends the package to the MQTT broker.
Method SendDISCONNECT() As %Status [ Internal, Private ]
{
	Quit ..PackSendMsg("", $$$MQTTDISCONNECT)
}

/// Creates a <b><var>PINGREQ</var></b> message and sends the package to the MQTT broker.
Method SendPINGREQ() As %Status [ Internal, Private ]
{
	Set tSC = ..PackSendMsg("", $$$MQTTPINGREQ)
	Set:$$$ISOK(tSC) ..lastPing = $ZDateTime($ZTimeStamp, 3, 1)
	
	Quit tSC
}

/// Creates the variable header and payload of a <b><var>SUBSCRIBE</var></b> message and sends the package to the MQTT broker.
Method SendSUBSCRIBE(pMessageId As %Integer, pTopics As %ListOfObjects, pDup As %Boolean = 0) As %Status [ Internal, Private ]
{
#dim topic As Net.MQTT.Message

	Set varhdr = $$$MQTTEncodeNumber(+pMessageId)
	
	Set payload = "", key = ""
	While 1 {
		Set topic = pTopics.GetNext(.key) Quit:(key = "")
		Set payload = payload _ ..GetUTFString(topic.Topic) _ $Char($Case(topic.QoSLevel, 2: $$$MQTTSubQoS2, 1: $$$MQTTSubQoS1, : 0))
	}
	
	Set tSC = ..PackSendMsg(varhdr_payload, $$$MQTTSUBSCRIBE, pDup, 1)
	Quit tSC
}

/// Creates the variable header and payload of an <b><var>UNSUBSCRIBE</var></b> message and sends the package to the MQTT broker.
Method SendUNSUBSCRIBE(pMessageId As %Integer, pTopics As %ListOfObjects, pDup As %Boolean = 0) As %Status [ Internal, Private ]
{
#dim topic As Net.MQTT.Message

	Set varhdr = $$$MQTTEncodeNumber(+pMessageId)
	
	Set payload = "", key = ""
	While 1 {
		Set topic = pTopics.GetNext(.key) Quit:(key = "")
		Set payload = payload _ ..GetUTFString(topic.Topic)
	}
	
	Set tSC = ..PackSendMsg(varhdr_payload, $$$MQTTUNSUBSCRIBE, pDup, 1)
	Quit tSC
}

/// Creates the variable header and payload of a <b><var>PUBLISH</var></b> message and sends the package to the MQTT broker.
Method SendPUBLISH(pMessage As Net.MQTT.MessageStore, pDup As %Boolean = 0) As %Status [ Internal, Private ]
{
	Set varhdr = ..GetUTFString(pMessage.Topic) _ $Select(pMessage.QoSLevel > 0: $$$MQTTEncodeNumber(+pMessage.MessageId), 1: "")
	
	Set tSC = ..PackSendMsg(varhdr_pMessage.Content, $$$MQTTPUBLISH, pDup, pMessage.QoSLevel, pMessage.Retain)
	Quit tSC
}

/// Creates the variable header of a <b><var>PUBACK</var></b> message and sends the package to the MQTT broker.
Method SendPUBACK(pMessageId As %Integer) As %Status [ Internal, Private ]
{
	Set varhdr = $$$MQTTEncodeNumber(+pMessageId)
	
	Set tSC = ..PackSendMsg(varhdr, $$$MQTTPUBACK)
	Quit tSC
}

/// Creates the variable header of a <b><var>PUBREC</var></b> message and sends the package to the MQTT broker.
Method SendPUBREC(pMessageId As %Integer) As %Status [ Internal, Private ]
{
	Set varhdr = $$$MQTTEncodeNumber(+pMessageId)
	
	Set tSC = ..PackSendMsg(varhdr, $$$MQTTPUBREC)
	Quit tSC
}

/// Creates the variable header of a <b><var>PUBREL</var></b> message and sends the package to the MQTT broker.
Method SendPUBREL(pMessageId As %Integer, pDup As %Boolean = 0) As %Status [ Internal, Private ]
{
	Set varhdr = $$$MQTTEncodeNumber(+pMessageId)
	
	Set tSC = ..PackSendMsg(varhdr, $$$MQTTPUBREL, pDup, 1)
	Quit tSC
}

/// Creates the variable header of a <b><var>PUBCOMP</var></b> message and sends the package to the MQTT broker.
Method SendPUBCOMP(pMessageId As %Integer) As %Status [ Internal, Private ]
{
	Set varhdr = $$$MQTTEncodeNumber(+pMessageId)
	
	Set tSC = ..PackSendMsg(varhdr, $$$MQTTPUBCOMP)
	Quit tSC
}

/// Evaluates a <b><var>CONNACK</var></b> message, received from the MQTT Broker and signals the initiator (<class>Net.MQTT.Client</class>)
///  via the <class>%SYSTEM.Event</class> API about the success or failure of the connection attempt.
Method RecvCONNACK(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ Internal, Private ]
{
	Set tSC = $$$OK
	
	Set ret = ""
	If $Length(pContent) '= 2 {
		Set tSC = $$$ERROR($$$GeneralError, "Invalid CONNACK message has arrived from <" _ ..Host _ ":" _ ..Port _ "> (length: " _ $Length(pContent) _ " <> 2)")
	}
	Else {
		Set ret = +$Ascii($Extract(pContent, 2))
		If ret = 1 { Set tSC = $$$ERROR($$$GeneralError, "Connection to <" _ ..Host _ ":" _ ..Port _ "> failed (unacceptable protocol version)") }
		ElseIf ret = 2 { Set tSC = $$$ERROR($$$GeneralError, "Connection to <" _ ..Host _ ":" _ ..Port _ "> failed (identifier rejected)") }
		ElseIf ret = 3 { Set tSC = $$$ERROR($$$GeneralError, "Connection to <" _ ..Host _ ":" _ ..Port _ "> failed (server unavailable)") }
		ElseIf ret = 4 { Set tSC = $$$ERROR($$$GeneralError, "Connection to <" _ ..Host _ ":" _ ..Port _ "> failed (bad username or password)") }
		ElseIf ret = 5 { Set tSC = $$$ERROR($$$GeneralError, "Connection to <" _ ..Host _ ":" _ ..Port _ "> failed (not authorized)") }
	}
	
	Do $System.Event.Signal("^MQTT.Connect(""" _ ..connectionId _ """)", $Select($$$ISOK(tSC): "", 1: $System.Status.GetErrorText(tSC)))
	
	Quit tSC
}

/// Evaluates a <b><var>PINGRESP</var></b> message, received from the MQTT Broker and clears the <property>lastPing</property> property,
///  so the Agent can know that the broker is still responsive and the connection is successfully kept alive.
Method RecvPINGRESP(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ Internal, Private ]
{
	Set tSC = $$$OK
	
	If pContent '= "" {
		Set tSC = $$$ERROR($$$GeneralError, "Invalid PINGRESP message has arrived from <" _ ..Host _ ":" _ ..Port _ ">")
	}
	Else {
		Set ..lastPing = ""
	}
	
	Quit tSC
}

/// Evaluates an <b><var>UNSUBACK</var></b> message, received from the MQTT Broker and 
///  signals the <class>Net.MQTT.Client</class> waiting for this acknowledge of a previously sent <b><var>UNSUBSCRIBE</var></b> message.
Method RecvUNSUBACK(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ CodeMode = expression, Internal, Private ]
{
..RecvAcknowledge("UNSUBACK", pDup, pQoS, pRetain, pContent)
}

/// Evaluates a <b><var>PUBACK</var></b> message, received from the MQTT Broker and 
///  signals the <class>Net.MQTT.Client</class> waiting for this acknowledge of a previously published QoS Level 1 message.
/// <p>This is the end of the message flow of the outgoing message.</p>
Method RecvPUBACK(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..RecvAcknowledge("PUBACK", pDup, pQoS, pRetain, pContent, .msgid)
	Set:$$$ISOK(tSC) tSC = ##class(Net.MQTT.Aux.MessageStatus).DoneMessageOut(..ClientId, msgid)

	Quit tSC
}

/// Evaluates a <b><var>PUBREC</var></b> message, received from the MQTT Broker and 
///  signals the <class>Net.MQTT.Client</class> waiting for this acknowledge of a previously published QoS Level 2 message.
/// <p>It also pushes the <class>Net.MQTT.Aux.MessageStatus</class> to the next state (a <b><var>PUBREL</var></b> message has to be sent).</p>
Method RecvPUBREC(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..RecvAcknowledge("PUBREC", pDup, pQoS, pRetain, pContent, .msgid)
	Set:$$$ISOK(tSC) tSC = ##class(Net.MQTT.Aux.MessageStatus).ReleaseMessageOut(..ClientId, msgid)

	Quit tSC
}

/// Evaluates a <b><var>PUBREL</var></b> message, received from the MQTT Broker.
/// <p>It pushes the <class>Net.MQTT.Aux.MessageStatus</class> to the next state (a <b><var>PUBCOMP</var></b> message has to be sent),
///  and cretes a new task (<class>Net.MQTT.Aux.TaskList</class>) to complete the next step of the QoS Level 2 message flow.</p>
Method RecvPUBREL(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..RecvAcknowledge("PUBREL", pDup, pQoS, pRetain, pContent, .msgid)
	Set:$$$ISOK(tSC) tSC = ##class(Net.MQTT.Aux.MessageStatus).CompleteMessageIn(..ClientId, msgid)
	Set:$$$ISOK(tSC) taskid = ##class(Net.MQTT.Aux.TaskList).CreateNewTask(..connectionId, msgid, "PUBCOMP", .tSC)

	Quit tSC
}

/// Evaluates a <b><var>PUBCOMP</var></b> message, received from the MQTT Broker and 
///  signals the <class>Net.MQTT.Client</class> waiting for this acknowledge of a previously published QoS Level 2 message.
/// <p>This is the end of the message flow of the outgoing message.</p>
Method RecvPUBCOMP(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..RecvAcknowledge("PUBCOMP", pDup, pQoS, pRetain, pContent, .msgid)
	Set:$$$ISOK(tSC) tSC = ##class(Net.MQTT.Aux.MessageStatus).DoneMessageOut(..ClientId, msgid)
	
	Quit tSC
}

/// Generic method for evaluating an acknowledge type message and signaling the appropriate process via the <class>%SYSTEM.Event</class> API
///  waiting for this acknowledge.
Method RecvAcknowledge(pType As %String, pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String, Output pMsgId As %Integer) As %Status [ Internal, Private ]
{
	Set tSC = $$$OK
	
	If $Length(pContent) '= 2 {
		Set tSC = $$$ERROR($$$GeneralError, "Invalid " _ pType _ " message has arrived from <" _ ..Host _ ":" _ ..Port _ "> (length: " _ $Length(pContent) _ " <> 2)")
	}
	Else {
		Set pMsgId = $$$MQTTDecodeNumber(pContent)
		Do ##class(Net.MQTT.Aux.TaskList).SignalAck(..connectionId, pMsgId, pType, $Select($$$ISOK(tSC): "", 1: $System.Status.GetErrorText(tSC)))
	}
	
	Quit tSC
}

/// Evaluates a <b><var>SUBACK</var></b> message, received from the MQTT Broker,
///  stores the QoS levels granted by the broker on the various items of the subscription message (see: <class>Net.MQTT.Aux.Subscription</class>)
///  and signals the <class>Net.MQTT.Client</class> waiting for this acknowledge of the previously sent <b><var>SUBSCRIBE</var></b> message.
Method RecvSUBACK(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ Internal, Private ]
{
	Set tSC = $$$OK
	
	If $Length(pContent) < 2 {
		Set tSC = $$$ERROR($$$GeneralError, "Invalid SUBACK message has arrived from <" _ ..Host _ ":" _ ..Port _ "> (length < 2)")
	}
	Else {
		Set msgid = $$$MQTTDecodeNumber($Extract(pContent, 1, 2))
		Set cnt = ##class(Net.MQTT.Aux.Subscription).GetTopicCount(..ClientId, msgid, .tSC)
		If $$$ISOK(tSC) {
			If $Length(pContent) '= (2 + cnt) {
				Set tSC = $$$ERROR($$$GeneralError, "Invalid SUBACK message has arrived from <" _ ..Host _ ":" _ ..Port _ "> (# of topics)")
			}
			Else {
				For i = 1: 1: cnt {
					Set tSC = ##class(Net.MQTT.Aux.Subscription).AckTopic(..ClientId, msgid, i, $Case($Ascii($Extract(pContent, 2 + i)), $$$MQTTSubQoS2: 2, $$$MQTTSubQoS1: 1, : 0))
					Quit:$$$ISERR(tSC)
				}
			}
		}
		Do ##class(Net.MQTT.Aux.TaskList).SignalAck(..connectionId, msgid, "SUBACK", $Select($$$ISOK(tSC): "", 1: $System.Status.GetErrorText(tSC)))
	}
	
	Quit tSC
}

/// Evaluates a <b><var>PUBLISH</var></b> message, received from the MQTT Broker and
///  stores the incoming message as a <class>Net.MQTT.MessageStore</class> object.
/// <p>If the QoS Level > 0, it also pushes the <class>Net.MQTT.Aux.MessageStatus</class> to the next state 
///  (either a <b><var>PUBACK</var></b> or <b><var>PUBREC</var></b> message has to be sent),
///  and cretes a new task (<class>Net.MQTT.Aux.TaskList</class>) to complete the next step of the message flow.</p>
Method RecvPUBLISH(pDup As %Boolean, pQoS As %Integer, pRetain As %Boolean, pContent As %String) As %Status [ Internal, Private ]
{
	Set tSC = $$$OK
	
	Set topicL = $$$MQTTDecodeNumber($Extract(pContent, 1, 2))
	Set topic = $Extract(pContent, 3, 2 + topicL)
	Set pos = 3 + topicL
	If pQoS > 0 {
		Set msgid = $$$MQTTDecodeNumber($Extract(pContent, pos, pos + 1))
		Set pos = pos + 2
	}
	Else {
		Set msgid = ""
	}

	TStart
	Set tSC = ##class(Net.MQTT.Aux.MessageStatus).%LockExtent(0)
	TRY {
		Set dup = $Select(pQoS > 0: pDup, 1: 0)
		If dup {
			Set dup = ##class(Net.MQTT.Aux.MessageStatus).IsRegisteredMessageIn(..ClientId, msgid)
		}
		If 'dup {
			If pQoS > 0 {
				Set tSC = ##class(Net.MQTT.Aux.MessageStatus).RegisterMessageIn(..ClientId, msgid, pQoS)
			}
			If $$$ISOK(tSC) {
				Set msg				= ##class(Net.MQTT.MessageStore).%New()
				Set msg.ClientId	= ..ClientId
				Set msg.Direction	= "I"
				Set msg.MessageId	= msgid
				Set msg.QoSLevel	= pQoS
				Set msg.Retain		= pRetain
				Set msg.Topic		= topic
				Set msg.Content		= $Extract(pContent, pos, *)
				Set tSC = msg.%Save()
				
				Set msg				= ##class(Net.MQTT.Message).%New()
				Set msg.MessageId	= msgid
				Set msg.QoSLevel	= pQoS
				Set msg.Retain		= pRetain
				Set msg.Topic		= topic
				Set msg.Content		= $Extract(pContent, pos, *)
				Set tSC = $ClassMethod("Net.MQTT.BMClient", "MyMessageHandler", msg, topic)
				set ^msg1($increment(^msg1)) = "OK"
			
			}
			If $$$ISOK(tSC) && (pQoS > 0) {
				Set taskid = ##class(Net.MQTT.Aux.TaskList).CreateNewTask(..connectionId, msgid, $Case(pQoS, 2: "PUBREC", : "PUBACK"), .tSC)
			}
		}
	}
	CATCH ex {
		Set tSC = ex.AsStatus()
	}
	Do ##class(Net.MQTT.Aux.MessageStatus).%UnlockExtent()
	If $$$ISOK(tSC) { TCommit }
	Else { TRollback }
		
	Quit tSC
}

Method CloseDev() [ Internal, Private ]
{
	If ..connected {
		$$$MQTTTraceINF("Agent for " _ ..ClientId _ " to <" _ ..Host _ ":" _ ..Port _ "> is stopping TCP connection")
		Close ..device
		Use ..saveIODev
		Set ..connected = 0, ..device = ""
	}
}

Method PackSendMsg(pMessage As %String, pMessageType As %Integer, pDup As %Boolean = 0, pQoS As %Integer = 0, pRetain As %Boolean = 0) As %Status [ Internal, Private ]
{
	Set header = $Char(pMessageType 
		+ $Select(pDup: $$$MQTTDup, 1: 0) 
		+ $Select(pRetain: $$$MQTTRetain, 1: 0) 
		+ $Case(pQoS, 2: $$$MQTTQoS2, 1: $$$MQTTQoS1, : 0)
	)

	Set lng = $Length(pMessage)
	While 1 {
		Set nxt = lng # 128
		Set lng = lng \ 128
		If lng > 0 {
			Set nxt = nxt + 128
		}
		Set header = header _ $Char(nxt)
		Quit:(lng '> 0)
	}

	Set msg = header_pMessage
	Write msg, !
	Set ..lastMessage = $ZDateTime($ZTimeStamp, 3, 1)
	$$$MQTTTraceOUT($$$MQTTMsgType(pMessageType), msg) 
	
	Quit $$$OK
}

ClassMethod GetMessageType(pHeader As %String) As %Integer
{
	Set a = $Factor($Ascii(pHeader))
	Set type = 0
	For i = 5: 1: 8 {
		Set type = type + ($Bit(a, i) * (2 ** (i - 1)))
	}
	 
	Quit type
}

ClassMethod IsDuplicate(pHeader As %String) As %Boolean
{
	Set a = $Factor($Ascii(pHeader))
	Set b = $Factor($$$MQTTDup)
	Quit $BitLogic(a & b) = b
}

ClassMethod GetQoSLevel(pHeader As %String) As %Integer
{
	Set a  = $Factor($Ascii(pHeader))
	Set q1 = $Factor($$$MQTTQoS1)
	Set q2 = $Factor($$$MQTTQoS2)
	Quit $Select($BitLogic(a & q2) = q2: 2, $BitLogic(a & q1) = q1: 1, 1: 0)
}

ClassMethod IsRetain(pHeader As %String) As %Boolean
{
	Set a = $Factor($Ascii(pHeader))
	Set b = $Factor($$$MQTTRetain)
	Quit $BitLogic(a & b) = b
}

Method GetUTFString(pString As %String) As %String
{
	Set tString = $ZCVT(pString, "O", ..transTable)
	Set tLen = $L(tString)
	
	Quit $$$MQTTEncodeNumber(tLen) _ tString
}

Storage Default
{
<Data name="AgentDefaultData">
<Subscript>"Agent"</Subscript>
<Value name="1">
<Value>connected</Value>
</Value>
<Value name="2">
<Value>device</Value>
</Value>
<Value name="3">
<Value>saveIODev</Value>
</Value>
<Value name="4">
<Value>transTable</Value>
</Value>
<Value name="5">
<Value>lastMessage</Value>
</Value>
<Value name="6">
<Value>lastPing</Value>
</Value>
<Value name="7">
<Value>fatalError</Value>
</Value>
</Data>
<DefaultData>AgentDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}

