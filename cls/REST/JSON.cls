Class REST.JSON Extends %Base
{

ClassMethod GetConnect(ClientID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%Object).$new()
   try { 
   
   // Defining and saving the client
   set client = ##class(Net.MQTT.Client).%New()
   set client.Host = "iot.eclipse.org"
   set client.ClientId = ClientID
   set client.traceTarget = "^MQTT.Trace"
   If $$$ISOK(status) {
    // Starting the agent
   	set status = client.StartAgent() 
   }
   set status = client.%Save()
 
   // Producement of a JSON (success)
   If $$$ISOK(status) {
    do object.$set("success", 1, "boolean")
    set object.clientObject = client.%Id()
   }
	   }
	   catch ex {
	   set status = ex.AsStatus()	
	   }
	   // Producement of a JSON (fail)
	   if $$$ISERR(status) 
	   {
  		do object.$set("success", 0, "boolean")
  		Set object.error = $System.Status.GetErrorText(status)
  		}
	write object.$toJSON()
	quit $$$OK
}

ClassMethod GetDisconnect(ClientObjectID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%Object).$new()
   try { 
   
   // Opening a client from DB and stopping the agent
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .st)
   set status = client.StopAgent()
   // Producement of a JSON (fail)
   If $$$ISERR(status) {
   	do object.$set("success", 0, "boolean")
   	Set object.error = $System.Status.GetErrorText(status)
   }
   
   // Deleting a client
   set status = ##class(Net.MQTT.Client).%DeleteId(ClientObjectID)
   // Producement of a JSON (fail)
   If $$$ISERR(status) {
   	do object.$set("success", 0, "boolean")
   	Set object.error = $System.Status.GetErrorText(status)
   }
  
   // Producement of a JSON (success)
   If $$$ISOK(status) {
    do object.$set("success", 1, "boolean")
   }
   		} 
   		catch ex {
	   	set status=ex.AsStatus()
	   	}
	   	// Producement of a JSON (fail)
	   	if $$$ISERR(status) {
  		do object.$set("success", 0, "boolean")
 		Set object.error = $System.Status.GetErrorText(st)
	  	}
	write object.$toJSON()
	quit $$$OK
}

ClassMethod PostSubscribe(ClientObjectID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%Object).$new()
   try {
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Opening a client from DB
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .status)
   // Producement of a JSON (fail)
   if $$$ISERR(status) {
	   do object.$set("success", 0, "boolean")
	   Set object.error = $System.Status.GetErrorText(status)
	   }
   
   // Defining mqtt message class and list of mqtt objects
   Set tpc = ##class(Net.MQTT.Message).%New()
   Set topics = ##class(%ListOfObjects).%New()
   
   // Creation of an abstract object and a subscription
   set JSON = ##class(%AbstractObject).$fromJSON(obj)
   for x=0:1:(JSON.$size()-1){
	   set tpc.Topic = JSON.$get(x).topicFilter
	   set tpc.QoSLevel = JSON.$get(x).qos
	   Do topics.Insert(tpc)
	   }
	   set status = client.Subscribe(.topics)
	   // Producement of a JSON (fail)
	   if $$$ISERR(status) {
  		do object.$set("success", 0, "boolean")
  		Set object.error = $System.Status.GetErrorText(status)
	  	}

   set topicArray = ##class(%Array).$new()
   //Making topics list parseable to JSON
   for x=1:1:(topics.Count()){
	   set topicget = topics.GetAt(x)
	   set topicobject = ##class(%Object).$new()
	   set topicobject.topicFilter = topicget.Topic
	   set topicobject.qos = topicget.QoSLevel
	   do topicArray.$push(topicobject)
	   }
   // Producement of a JSON (success)
   If $$$ISOK(status) {
    do object.$set("success", 1, "boolean")
   }
   set object.topics = topicArray
  
 
   		} catch ex {
       	set status=ex.AsStatus()
       	}
	   	if $$$ISERR(status) {
  		// Creation of dynamic object and producement of a JSON (fail)
  		do object.$set("success", 0, "boolean")
  		Set object.error = $System.Status.GetErrorText(status)
		}
	// Producement of a JSON (success)
	write object.$toJSON()
	quit $$$OK
}

ClassMethod PostUnsubscribe(ClientObjectID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%Object).$new()
   try { 
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Opening a client from DB
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .status)
   If $$$ISERR(status) {
   	do object.$set("success", 0, "boolean")
   	Set object.error = $System.Status.GetErrorText(status)
   }
   
   // Defining mqtt message class and list of mqtt objects
   Set tpc = ##class(Net.MQTT.Message).%New()
   Set topics = ##class(%ListOfObjects).%New()
   
   // Producement of a JSON
   set JSON = ##class(%AbstractObject).$fromJSON(obj)
   for x=0:1:(JSON.$size()-1){
	   set tpc.Topic = JSON.$get(x).topicFilter
	   Do topics.Insert(tpc)
	   }
	   set status = client.Unsubscribe(.topics)
	   // Producement of a JSON (success)
   		If $$$ISOK(status) {
    	do object.$set("success", 1, "boolean")
   		}
	   // Producement of a JSON (fail)
	   if $$$ISERR(status) {
  		do object.$set("success", 0, "boolean")
  		Set object.error = $System.Status.GetErrorText(status)
       }
   
  } catch ex {
       set status=ex.AsStatus()
       // Producement of a JSON (fail)
       if $$$ISERR(status) {
  		do object.$set("success", 0, "boolean")
  		Set object.error = $System.Status.GetErrorText(status)
       }
	}
	// Producement of a JSON (success)
	write object.$toJSON()
	quit $$$OK
}

ClassMethod PostPublish(ClientObjectID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%Object).$new()
   try { 
   
   // Opening a client from DB and publishing a message
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .status)
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Defining mqtt message class and list of mqtt objects
   Set message = ##class(Net.MQTT.Message).%New()
   
   // Creation of abstract object and producement of a JSON
   set JSON = ##class(%AbstractObject).$fromJSON(obj)
   
	   set message.Topic = JSON.topicName
	   set message.QoSLevel = JSON.qos
	   set message.Retain = JSON.retain
	   set message.Content = JSON.content
	   set status = client.Publish(message)
	   If $$$ISOK(status) {
    	do object.$set("success", 1, "boolean")
    	}
   	} catch ex {
       set status=ex.AsStatus()
       }
	// Producement of a JSON (fail)
    if $$$ISERR(status) {
  	Set object.success = 0
  	Set object.error = $System.Status.GetErrorText(status)
  	}
	write object.$toJSON()
	quit $$$OK
}

ClassMethod GetLastMessages() As %Status
{
   set status=$$$OK
   try {    
   	do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,"select top 5 DeviceID,SensorType from Net_MQTT.Storage")
   } catch ex {
       set status=ex.AsStatus()
   }
   quit status
}

}

