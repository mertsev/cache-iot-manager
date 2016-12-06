/// Auxiliary class to provide unique Message Identifiers for in-flight messages of a specific client connection.
/// <p>MQTT standard only specifies that Message Identifiers must be unique among the currently in-flight messages.
/// This class helps to initialize a new message sequence for each Client (<class>Net.MQTT.Client</class>) / Agent (<class>Net.MQTT.Agent</class>) pairs,
///  based on the <property>ClientId</property>. This also means that <property>ClientId</property> must be unique among parallel
///  Client instances currently running in the same database.</p>
Class Net.MQTT.Auxiliary.MessageCounter Extends %Persistent
{

Index ClientKey On ClientId [ IdKey, PrimaryKey ];

Property ClientId As %String [ Required ];

Property LastMessageId As %Integer(MAXVAL = 65535, MINVAL = 0) [ InitialExpression = 0 ];

/// Used internally, by <class>Net.MQTT.Client</class> instances to create a new Message Identifier sequence.
/// for a <property>ClientId</property> (which must be unqique among the currently running Clients). 
ClassMethod CreateCounter(pClientId As %String) As %Status
{
	Set tSC = ..%LockExtent(0)
	TRY {
		If ..%ExistsId(pClientId) {
			Set tSC = $$$ERROR($$$GeneralError, "Client ID ('" _ pClientId _ "') is already used")
		}
		Else {
			Set obj = ..%New()
			Set obj.ClientId = pClientId
			Set tSC = obj.%Save()
		}
	}
	CATCH ex {
		Set tSC = ex.AsStatus()
	}
	Do ..%UnlockExtent()
	Quit tSC
}

/// Used internally, by <class>Net.MQTT.Client</class> instances.
/// <p>Returns the next available Message Idenfier for a specific <property>ClientId</property>.</p>
/// <p>Currently MQTT Message Identifiers must fall between 1 and 65535. After 65535 the counter simply turns into 1 again,
/// simply assuming that this cannot lead to a collision among current in-flight messages.</p>
ClassMethod NextMessageId(pClientId As %String, ByRef pSC As %Status) As %Integer
{
	Set obj = ..%OpenId(pClientId, 4, .pSC)
	If $$$ISOK(pSC) {
		Set obj.LastMessageId = $Case(obj.LastMessageId, 65535: 1, : obj.LastMessageId + 1)
		Set pSC = obj.%Save()
	}
	Quit $Select($$$ISOK(pSC): obj.LastMessageId, 1: "")
}

/// Used internally, by <class>Net.MQTT.Client</class> instances.
/// <p>Deletes the corresponding counter, when a Client is about to stop (more specifically: when its <class>Net.MQTT.Agent</class> is stopped).</p>
ClassMethod DropCounter(pClientId As %String) As %Status [ CodeMode = expression ]
{
..%DeleteId(pClientId, 4)
}

Storage Default
{
<Data name="MessageCounterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>LastMessageId</Value>
</Value>
</Data>
<DataLocation>^Net.MQTT.Aux93C.MessageCounterD</DataLocation>
<DefaultData>MessageCounterDefaultData</DefaultData>
<IdLocation>^Net.MQTT.Aux93C.MessageCounterD</IdLocation>
<IndexLocation>^Net.MQTT.Aux93C.MessageCounterI</IndexLocation>
<StreamLocation>^Net.MQTT.Aux93C.MessageCounterS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

