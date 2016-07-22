Class REST.JSON Extends %Base
{

ClassMethod GetAllMessages(Table As %String) As %Status
{
    
   set st=$$$OK
   try {    
   do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,"select * from " _ Table)
   } catch ex {
       set st=ex.AsStatus()
   }
   quit st
}

ClassMethod GetConnect(ClientID As %String) As %Status
{
	set st=$$$OK
   try { 
   
   // Defining a message
   Set message = ##class(Net.MQTT.Message).%New()
   Set message.Topic = "/isctest/client/rest"
   Set message.Content = "GetConnect method is working!" _ " ClientID is " _ ClientID
   Set message.QoSLevel = 2
   
   // Defining a client and sending a message to mqtt
   set client = ##class(Net.MQTT.Client).%New()
   set client.Host = "iot.eclipse.org"
   set client.ClientId = ClientID
   set sc = client.StartAgent() 
   Set sc = client.Publish(message)
   set status = client.%Save()
   
   // Creation of dynamic object and producement of a JSON
   set object = ##class(%Object).$new()
   set object.success = 1
   set object.error = "if any"
   set object.clientObject = ClientID
   write object.$toJSON()
   
   } catch ex {
	   set st=ex.AsStatus()
	   }
   quit st
}

ClassMethod GetDisconnect(ClientObjectID As %String) As %Status
{
	set st=$$$OK
   try { 
   
   // Opening a client from DB and stopping the agent
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .st)
   set sc = client.StopAgent()
   
   // Creation of dynamic object and producement of a JSON
   set object = ##class(%Object).$new()
   set object.success = 1
   set object.error = "if any"
   write object.$toJSON()
   
   } catch ex {
	   set st=ex.AsStatus()
	   w st
	   }
   quit st
}

ClassMethod PostSubscribe(ClientObjectID As %String) As %Status
{
	set st=$$$OK
   try {
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Opening a client from DB
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .st)
   
   // Defining mqtt message class and list of mqtt objects
   Set tpc = ##class(Net.MQTT.Message).%New()
   Set topics = ##class(%ListOfObjects).%New()
   
   // Creation of abstract object and creation of a subscription
   set JSON = ##class(%AbstractObject).$fromJSON(obj)
   for x=0:1:(JSON.$size()-1){
	   set tpc.Topic = JSON.$get(x).topicFilter
	   set tpc.QoSLevel = JSON.$get(x).qos
	   Do topics.Insert(tpc)
	   }
	   set sc = client.Subscribe(.topics)
    
   // Creation of dynamic object and producement of a JSON
   set object = ##class(%Object).$new()
   set object.success = 1
   set object.error = ""
   set topicArray = ##class(%Array).$new()
   //Making topics list parseable to JSON
   for x=0:1:(topics.Count()){
	   set topicget = topics.GetAt(x)
	   set topicobject = ##class(%Object).$new()
	   set topicobject.topicFilter = topicget.Topic
	   set topicobject.qos = topicget.QoSLevel
	   do topicArray.$push(topicobject)
	   }
   set object.topics = topicArray
   write object.$toJSON()
	 
 
   } catch ex {
       set st=ex.AsStatus()
}
	quit st
}

ClassMethod PostUnsubscribe(ClientObjectID As %String) As %Status
{
	set st=$$$OK
   try { 
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Opening a client from DB
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .st)
   
   // Defining mqtt message class and list of mqtt objects
   Set tpc = ##class(Net.MQTT.Message).%New()
   Set topics = ##class(%ListOfObjects).%New()
   
   // Creation of abstract object and producement of a JSON
   set JSON = ##class(%AbstractObject).$fromJSON(obj)
   for x=0:1:(JSON.$size()-1){
	   set tpc.Topic = JSON.$get(x).topicFilter
	   Do topics.Insert(tpc)
	   }
	   set sc = client.Unsubscribe(topics)
   
  } catch ex {
       set st=ex.AsStatus()
}
	quit st
}

ClassMethod PostPublish(ClientObjectID As %String) As %Status
{
	set st=$$$OK
   try { 
   
   // Opening a client from DB and publishing a message
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .st)
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Defining mqtt message class and list of mqtt objects
   Set message = ##class(Net.MQTT.Message).%New()
   
   // Creation of abstract object and producement of a JSON
   set JSON = ##class(%AbstractObject).$fromJSON(obj)
   for x=0:1:(JSON.$size()-1){
	   set message.Topic = JSON.$get(x).topicName
	   set message.QoSLevel = JSON.$get(x).qos
	   set message.Retain = JSON.$get(x).retain
	   set message.Content = JSON.$get(x).content
	   }
	   set sc = client.Publish(message)
   
   } catch ex {
       set st=ex.AsStatus()
}
	quit st
}

ClassMethod PostMessages(ClientObjectID As %String) As %Status
{
	set st=$$$OK
   try { 
   // Opening a client from DB and ?
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .st)
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Creation of abstract object and producement of a JSON
   set consumedJSON = ##class(%AbstractObject).$fromJSON(obj)
   write consumedJSON.$toJSON()
   
   } catch ex {
       set st=ex.AsStatus()
}
	quit st
}

ClassMethod GetLastMessage() As %Status
{
    
   set st=$$$OK
   try {    
   do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,"select top 5 DeviceID,SensorType from Net_MQTT.Storage")
   } catch ex {
       set st=ex.AsStatus()
   }
   quit st
}

}

