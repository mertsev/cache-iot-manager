/// Auxiliary class used only internally to keep track of QoS level 1-2 message, while they're waiting for completion of the communication.
/// <class>This class is used only internally by the <class>Net.MQTT.Client</class> and <class>Net.MQTT.Agent</class> classes.
/// <p>Messages are delete from this class, as soon as the corresponding message flow is completed.</p>
Class Net.MQTT.Auxiliary.MessageStatus Extends %Persistent
{

Index ClientKey On (ClientId, Direction, MessageId) [ Unique ];

Property ClientId As %String(MAXLEN = 23) [ Required ];

Property Direction As %String(VALUELIST = ",I,O") [ Required ];

Property MessageId As %Integer(MAXVAL = 65535, MINVAL = 1) [ InitialExpression = 0 ];

Property Status As %String(VALUELIST = ",SUBSCRIBE,UNSUBSCRIBE,PUBLISH,PUBACK,PUBREC,PUBREL,PUBCOMP,DONE") [ Required ];

ClassMethod RegisterMessageIn(pClientId As %String, pMessageId As %String, pQoSLevel As %Integer) As %Status [ CodeMode = expression ]
{
..RegisterNew(pClientId, pMessageId, "I", $Case(pQoSLevel, 2: "PUBREC", : "PUBACK"))
}

ClassMethod IsRegisteredMessageIn(pClientId As %String, pMessageId As %String) As %Boolean [ CodeMode = expression ]
{
..ClientKeyExists(pClientId, "I", pMessageId)
}

ClassMethod ReleaseMessageIn(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..Update(pClientId, "I", pMessageId, "PUBREL")
}

ClassMethod CompleteMessageIn(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..Update(pClientId, "I", pMessageId, "PUBCOMP")
}

ClassMethod DoneMessageIn(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..Done(pClientId, "I", pMessageId)
}

ClassMethod RegisterMessageOut(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..RegisterNew(pClientId, pMessageId, "O", "PUBLISH")
}

ClassMethod AcknowledgeMessageOut(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..Update(pClientId, "O", pMessageId, "PUBACK")
}

ClassMethod ReceiveMessageOut(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..Update(pClientId, "O", pMessageId, "PUBREC")
}

ClassMethod ReleaseMessageOut(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..Update(pClientId, "O", pMessageId, "PUBREL")
}

ClassMethod CompleteMessageOut(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..Update(pClientId, "O", pMessageId, "PUBCOMP")
}

ClassMethod DoneMessageOut(pClientId As %String, pMessageId As %String) As %Status [ CodeMode = expression ]
{
..Done(pClientId, "O", pMessageId)
}

ClassMethod RegisterNew(pClientId As %String, pMessageId As %String, pDirection As %String, pStatus As %String) As %Status [ Internal, Private ]
{
	Set msgid = ""
	Set tSC = ..%LockExtent(0)
	If $$$ISERR(tSC) { Quit tSC }
	
	TRY {
		Set obj = ..%New()
		Set obj.ClientId = pClientId
		Set obj.Direction = pDirection
		Set obj.MessageId = pMessageId
		Set obj.Status = pStatus
		Set tSC = obj.%Save()
	}
	CATCH ex {
		Set pSC = ex.AsStatus()
	}
	Do ..%UnlockExtent()
	
	Quit tSC
}

ClassMethod Update(pClientId As %String, pDirection As %String, pMessageId As %String, pStatus As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..%LockExtent(0)
	If $$$ISERR(tSC) { Quit tSC }

	TRY {
		Set obj = ..ClientKeyOpen(pClientId, pDirection, pMessageId, 0, .tSC)
		If $$$ISOK(tSC) {
			Set obj.Status = pStatus
			Set tSC = obj.%Save()
		}
		Else {
			Set tSC = $$$ERROR($$$GeneralError, "Message ID (" _ pDirection _ "," _ pMessageId _ ") cannot be updated for " _ pClientId)
		}
	}
	CATCH ex {
		Set tSC = ex.AsStatus()
	}
	Do ..%UnlockExtent()
	
	Quit tSC
}

ClassMethod Done(pClientId As %String, pDirection As %String, pMessageId As %String) As %Status [ Internal, Private ]
{
	Set tSC = ..%LockExtent(0)
	If $$$ISERR(tSC) { Quit tSC }

	TRY {
		Set exists = ..ClientKeyExists(pClientId, pDirection, pMessageId, .id)
		If exists {
			Set tSC = ..%DeleteId(id, 0)
		}
		Else {
			Set tSC = $$$ERROR($$$GeneralError, "Message ID (" _ pDirection _ "," _ pMessageId _ ") does not currently exists for " _ pClientId)
		}
	}
	CATCH ex {
		Set pSC = ex.AsStatus()
	}
	Do ..%UnlockExtent()
	
	Quit tSC
}

Storage Default
{
<Data name="MessageStatusDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ClientId</Value>
</Value>
<Value name="3">
<Value>Direction</Value>
</Value>
<Value name="4">
<Value>MessageId</Value>
</Value>
<Value name="5">
<Value>Status</Value>
</Value>
</Data>
<DataLocation>^Net.MQTT.Auxi93C.MessageStatusD</DataLocation>
<DefaultData>MessageStatusDefaultData</DefaultData>
<IdLocation>^Net.MQTT.Auxi93C.MessageStatusD</IdLocation>
<IndexLocation>^Net.MQTT.Auxi93C.MessageStatusI</IndexLocation>
<StreamLocation>^Net.MQTT.Auxi93C.MessageStatusS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

