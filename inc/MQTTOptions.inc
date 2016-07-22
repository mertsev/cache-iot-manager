#; General
#define MQTTTraceIN(%type,%msg)		$$$MQTTTrace(%type,"I",%msg)
#define MQTTTraceOUT(%type,%msg)	$$$MQTTTrace(%type,"O",%msg)
#define MQTTTraceINF(%msg)			$$$MQTTTrace("INFO","S",%msg)
#define MQTTTraceERR(%msg)			$$$MQTTTrace("ERROR","S",%msg)
#define MQTTTrace(%type,%dir,%msg)	Set:(..trace) var=..traceTarget,@var@($I(@var),$ZDT($ZU(188),3,1,3),%dir,$Case(%type,"":"UNKNOWN",:%type))=%msg
#define MQTTEncodeNumber(%num)		$Reverse($ZWChar(%num))
#define MQTTDecodeNumber(%str)		$ZWAscii($Reverse(%str))

#; Fixed header
#define MQTTRetain			1
#define MQTTQoS1			2
#define MQTTQoS2			4
#define MQTTDup				8

#; Message types
#define MQTTCONNECT			16
#define MQTTCONNACK			32
#define MQTTPUBLISH			48
#define MQTTPUBACK			64
#define MQTTPUBREC			80
#define MQTTPUBREL			96
#define MQTTPUBCOMP			112
#define MQTTSUBSCRIBE		128
#define MQTTSUBACK			144
#define MQTTUNSUBSCRIBE		160
#define MQTTUNSUBACK		176
#define MQTTPINGREQ			192
#define MQTTPINGRESP		208
#define MQTTDISCONNECT		224
#define MQTTMsgType(%code)	$Case(%code,$$$MQTTCONNECT:"CONNECT",$$$MQTTCONNACK:"CONNACK",$$$MQTTPUBLISH:"PUBLISH",$$$MQTTPUBACK:"PUBACK",$$$MQTTPUBREC:"PUBREC",$$$MQTTPUBREL:"PUBREL",$$$MQTTPUBCOMP:"PUBCOMP",$$$MQTTSUBSCRIBE:"SUBSCRIBE",$$$MQTTSUBACK:"SUBACK",$$$MQTTUNSUBSCRIBE:"UNSUBSCRIBE",$$$MQTTUNSUBACK:"UNSUBACK",$$$MQTTPINGREQ:"PINGREQ",$$$MQTTPINGRESP:"PINGRESP",$$$MQTTDISCONNECT:"DISCONNECT",:"Unkown")

#; CONNECT
#define MQTTCleanSession	2
#define MQTTWillFlag		4
#define MQTTWillQoS1		8
#define MQTTWillQoS2		16
#define MQTTWillRetain		32
#define MQTTPasswordFlag	64
#define MQTTUsernameFlag	128

#; SUBSCRIBE
#define MQTTSubQoS1			1
#define MQTTSubQoS2			2
			