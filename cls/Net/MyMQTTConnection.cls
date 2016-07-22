Class Net.MyMQTTConnection Extends %RegisteredObject
{

// just comment

Method CreateConnection() As %Status
{
	Set ..client = ##class(Net.MQTT.Client).%New()
	Set ..client.Host = "iot.eclipse.org"
	Set ..client.ClientId = "client" _ $RANDOM(10000)
	Set ..client.traceTarget = "^MQTT.Trace"
	Set ..client.OnMessage = "Net.MQTT.BMClient:MyMessageHandler"
	
	Set sc = ..client.StartAgent() 
	If ('sc) { 
		Do $System.OBJ.DisplayError(sc) 
		write !, "Can't create communication" 
	}
	
	return sc
}

Method SendMessage(pContent As %String, pTopic As %String = "/isctest/client/Test") As %Status
{
	Set message = ##class(Net.MQTT.Message).%New()
	Set message.Topic = pTopic
	Set message.QoSLevel = 2
	Set message.Content = pContent

	Set sc = ..client.Publish(message) 
	If ('sc) {
		Do $System.OBJ.DisplayError(sc)
		write !, "Can't send the message" 
	}
#;	ZWrite ^MQTT.Trace	

	return sc
}

Method CloseConnection() As %Status
{
	Set sc = ..client.StopAgent() 
	If ('sc) { 
		Do $System.OBJ.DisplayError(sc) 
		write !, "Can't close connection"
	}
	
	return sc
}

Method Subscribe(pTopic As %String = "/isctest/client/#") As %Status
{
	Set tpc = ##class(Net.MQTT.Message).%New()
	Set tpc.Topic = pTopic
	Set tpc.QoSLevel = 2
	Set topics = ##class(%ListOfObjects).%New()
	Do topics.Insert(tpc)
	Set ..myTopic = topics
	
	Set sc = ..client.Subscribe(.topics)
	If ('sc) {
		Do $System.OBJ.DisplayError(sc)
		write !, "Can't subscribe topic"
		return sc
	}
	If (''sc) {
		Set t=topics.GetAt(1)
		Write "Topic:'"_t.Topic_"'; Expected QoS:"_t.QoSLevel_"; Granted QoS:"_t.GrantedQoS_";", ! 
	}
	return sc
}

Method Unsubscribe() As %Status
{
	set topics = ..myTopic
	
	Set sc = ..client.Unsubscribe(.topics)
	If ('sc) {
		Do $System.OBJ.DisplayError(sc)
		return sc
	}
	
	Set sc = ..client.StopAgent()
	If ('sc) {
		Do $System.OBJ.DisplayError(sc)
	}
	
	set ..myTopic = ""
	return sc
#;	ZWrite ^MQTT.Trace
}

Method TestStore() As %Status
{
	try {
	set jstring = "{""accuracy"":11, ""values"":[1, 2, 3], ""name"":""namestr""}"
	
	set newObject = ##class(%AbstractObject).$fromJSON(jstring)
	
	set s = ##class(Net.MQTT.Aux.Storege).%New()
	set s.DeviceID = "sdfsfsddf"
	set s.CreatedAt = $p($h, ",", 1)
	set s.SensorType = newObject.name
	set s.Value1 = newObject.values.$get(0)
	set s.Value2 = newObject.values.$get(1)
	set s.Value3 = newObject.values.$get(2)
	}
		CATCH ex {
		Set tSC = ex.AsStatus()
	}
	
	return s.%Save()
}

Property client As Net.MQTT.Client;

Property myTopic As %ListOfObjects;

}

