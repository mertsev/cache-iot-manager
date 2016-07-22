/// This structure is used as the input / output parameter type of multiple <class>Net.MQTT.Client</clas> methods.
Class Net.MQTT.Message Extends (%RegisteredObject, %XML.Adaptor)
{

/// Message Identifier. Usually it doesn't have to be set, when used as an input parameter. 
Property MessageId As %Integer(MAXVAL = 65535, MINVAL = 1);

Property Topic As %String;

Property Content As %String(MAXLEN = "");

/// Quality of service, expected / provided by the client.<ul>
/// <li><b><var>0</var></b> - no guaranteed message delivery.</li>
/// <li><b><var>1</var></b> - at least once delivery (simple acknowledge).</li>
/// <li><b><var>2</var></b> - exactly once delivery (two level acknowledges).</li>
/// </ul>
Property QoSLevel As %Integer(VALUELIST = ",0,1,2");

/// In case of subscriptions, this is the quality of service, provided by the server (may differ from the one expected by the client).
/// <br/>For details see <property>QoSLevel</property>
Property GrantedQoS As %Integer(VALUELIST = ",0,1,2");

/// In some message flows (publish, subscribe) may show, whether the server is expected to keep the message,
///  even after the client disconnects.
Property Retain As %Boolean;

}

