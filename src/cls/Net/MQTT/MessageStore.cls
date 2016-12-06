/// Sample message store for messages published by or recieved by <class>Net.MQTT.Client</class> and <class>Net.MQTT.Agent</class> instances.
/// <p>This could be implemented different ways. For example: this implementation does not care about duplicate messages.</p>
/// <p>In this sample MQTT Client implementation this class just stores all the incoming and outgoing messages unconditionally.</p>
/// <p>For more documentation of message properties see: <class>Net.MQTT.Message</class>.</p>
Class Net.MQTT.MessageStore Extends %Persistent
{

Index MsgIdx On (ClientId, Topic);

Property ClientId As %String(MAXLEN = 23) [ Required ];

Property Topic As %String(MAXLEN = "") [ Required ];

/// Direction of the message: <b><var>I</var></b> is for <var>input</var> (subscribe), <b><var>O</var></b> is for <var>output</var> (publish). 
Property Direction As %String(VALUELIST = ",I,O") [ InitialExpression = "I", Required ];

Property MessageId As %Integer(MAXVAL = 65653, MINVAL = 1);

Property Content As %String(MAXLEN = "");

Property QoSLevel As %Integer(VALUELIST = ",0,1,2");

Property GrantedQoS As %Integer(VALUELIST = ",0,1,2");

Property Retain As %Boolean;

Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDateTime($ZTimestamp, 3)}, Required ];

Storage Default
{
<Data name="MessageStoreDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ClientId</Value>
</Value>
<Value name="3">
<Value>Topic</Value>
</Value>
<Value name="4">
<Value>MessageId</Value>
</Value>
<Value name="5">
<Value>Content</Value>
</Value>
<Value name="6">
<Value>QoSLevel</Value>
</Value>
<Value name="7">
<Value>GrantedQoS</Value>
</Value>
<Value name="8">
<Value>Retain</Value>
</Value>
<Value name="9">
<Value>CreatedAt</Value>
</Value>
<Value name="10">
<Value>Direction</Value>
</Value>
</Data>
<DataLocation>^Net.MQTT.MessageStoreD</DataLocation>
<DefaultData>MessageStoreDefaultData</DefaultData>
<IdLocation>^Net.MQTT.MessageStoreD</IdLocation>
<IndexLocation>^Net.MQTT.MessageStoreI</IndexLocation>
<StreamLocation>^Net.MQTT.MessageStoreS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

