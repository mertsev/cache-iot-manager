Include MQTTOptions

/// Auxiliary class is used only internally by a <class>Net.MQTT.Client</class> and its <class>Net.MQTT.Agent</class> to keep track of 
/// <b><var>SUBSCRIBE</var></b> and <b><var>UNSUBSCRIBE</var></b> message contents.
/// <p>These messages must have a unique Message Idenfier among current in-flight messages (per Client), 
///  therefore all instances are dropped as soon as the corresponding message flow is completed.</p>
Class Net.MQTT.Auxiliary.Subscription Extends %Persistent
{

Index ClientKey On (ClientId, MessageId) [ Unique ];

Property ClientId As %String(MAXLEN = 23) [ Required ];

Property MessageId As %Integer(MAXVAL = 65653, MINVAL = 1) [ Required ];

Relationship Topics As Net.MQTT.Auxiliary.SubscriptionTopic [ Cardinality = children, Inverse = Subscription ];

ClassMethod CreateSubscription(pClientId As %String, pMessageId As %String, ByRef pSC As %Status) As Net.MQTT.Auxiliary.Subscription
{
	Set obj = ..%New()
	Set obj.ClientId = pClientId
	Set obj.MessageId = pMessageId
	Set pSC = obj.%Save()
	
	Quit $Select($$$ISOK(pSC): obj, 1: "")
}

ClassMethod DropSubscription(pId As %String) As %Status [ CodeMode = expression ]
{
..%DeleteId(pId)
}

Method AddTopic(pTopic As Net.MQTT.Message) As %Status
{
	Set obj = ##class(Net.MQTT.Auxiliary.SubscriptionTopic).%New()
	Set obj.Topic = pTopic.Topic
	Set obj.QoSLevel = pTopic.QoSLevel
	Set tSC = ..Topics.Insert(obj)
	Set:$$$ISOK(tSC) tSC = ..%Save()
	
	Quit tSC
}

ClassMethod GetTopicCount(pClientId As %String, pMessageId As %String, ByRef pSC As %Status) As %Integer
{
	Set ret = ""
	Set obj = ..ClientKeyOpen(pClientId, pMessageId, 0, .pSC)
	If $$$ISOK(pSC) {
		Set ret = obj.Topics.Count()
	}
	
	Quit ret
}

ClassMethod GetTopicList(pClientId As %String, pMessageId As %String, ByRef pSC As %Status) As %ListOfObjects(ELEMENTTYPE="Net.MQTT.Message")
{
 	Set ret = ##class(%ListOfObjects).%New()
	Set obj = ..ClientKeyOpen(pClientId, pMessageId, -1, .pSC)
	If $$$ISOK(pSC) {
		For i = 1: 1: obj.Topics.Count() {
			Set next = obj.Topics.GetAt(i)
			
			Set msg = ##class(Net.MQTT.Message).%New()
			Set msg.Topic = next.Topic
			Set msg.QoSLevel = next.QoSLevel
			Set pSC = ret.Insert(msg)
			Quit:$$$ISERR(pSC)
		}
	}
 	
	Quit $Select($$$ISOK(pSC): ret, 1: "")
}

ClassMethod AckTopic(pClientId As %String, pMessageId As %String, pTopicNr As %Integer, pGrantedQoS As %Integer) As %Status
{
	Set obj = ..ClientKeyOpen(pClientId, pMessageId, -1, .tSC)
	If $$$ISOK(tSC) {
		If (pTopicNr < 1) || (pTopicNr > obj.Topics.Count()) {
			Set tSC = $$$ERROR($$$GeneralError, "Inavlid topic number (" _ pTopicNr _ " is not between 1 and " _ obj.Topics.Count() _ ")")
		}
		Else {
			Set topic = obj.Topics.GetAt(pTopicNr)
			Set topic.GrantedQoS = pGrantedQoS
			Set tSC = topic.%Save()
		}
	}
	
	Quit tSC
}

Method RetrieveAck(ByRef pTopics As %ListOfObjects(ELEMENTTYPE="Net.MQTT.Message")) As %Status
{
	Set tSC = ..%Reload()
	If $$$ISOK(tSC) {
		If pTopics.Count() '= ..Topics.Count() {
			Set tSC = $$$ERROR($$$GeneralError, "Topic count mismatch (" _ pTopics.Count() _ " <> " _ ..Topics.Count() _ ")")
		}
		Else {
			For i = 1: 1: pTopics.Count() {
				Set pTopics.GetAt(i).GrantedQoS = ..Topics.GetAt(i).GrantedQoS
			}
		}
	}
	
	Quit tSC
}

Storage Default
{
<Data name="SubscriptionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ClientId</Value>
</Value>
<Value name="3">
<Value>MessageId</Value>
</Value>
</Data>
<DataLocation>^Net.MQTT.Auxil93C.SubscriptionD</DataLocation>
<DefaultData>SubscriptionDefaultData</DefaultData>
<IdLocation>^Net.MQTT.Auxil93C.SubscriptionD</IdLocation>
<IndexLocation>^Net.MQTT.Auxil93C.SubscriptionI</IndexLocation>
<StreamLocation>^Net.MQTT.Auxil93C.SubscriptionS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

