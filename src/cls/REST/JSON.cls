Class REST.JSON Extends %Base
{

Parameter TRACETARGET As %String = "^MQTT.Trace";

Parameter ONMESSAGE As %String = "Net.MQTT.BMClient:MyMessageHandler";

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
   set client.traceTarget = ..#TRACETARGET
   set client.OnMessage = ..#ONMESSAGE
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
  	do object.$set("success", 0, "boolean")
  	Set object.error = $System.Status.GetErrorText(status)
  	}
	write object.$toJSON()
	quit $$$OK
}

ClassMethod GetLastMessages() As %Status
{
   set status=$$$OK
   // Definition of dynamic json object
   set object = ##class(%Object).$new()
   set queryArray = ##class(%Array).$new()
   set object.data = queryArray

   // Execution of the query
   #sqlcompile select = display
   TRY {
  	&sql(DECLARE c1 CURSOR FOR 
  	SELECT 
  	info.DeviceID AS device, info.SensorType AS sensor, info.CreatedAt AS created, 
  	info.Value1 AS val1, info.Value2 AS val2, info.Value3 AS val3
  	INTO :device, :sensor, :created, :value1, :value2, :value3
	FROM 
  	Net_MQTT.Storage AS info
	INNER JOIN
	( 
  	SELECT DeviceID, SensorType, MAX(ID) AS ID FROM Net_MQTT.Storage
  	GROUP BY DeviceID, SensorType
	) AS lastmsg
	ON info.ID = lastmsg.ID
	ORDER BY sensor, device
  	)
  	If '$Get(SQLCODE, 0) { &sql(OPEN c1) }
  	If $Get(SQLCODE, 0) { Set status = $$$ERROR($$$SQLError, SQLCODE, "Problem while opening 'c1'") }
  
  	While $$$ISOK(status) {
	  	&sql(FETCH c1) Quit:SQLCODE
	  	set record = ##class(%Object).$new()
	  	set record.device = device 
	  	set record.sensor = sensor
	  	set record.created = created
	  	set record.value1 = value1
	  	set record.value2 = value2
	  	set record.value3 = value3
	  	do queryArray.$push(record)
 	}
 	
 	If $$$ISOK(status) && $Get(SQLCODE, 0) && (SQLCODE '= 100) {
    	Set status = $$$ERROR($$$SQLError, SQLCODE, "Problem while fetching 'c1'")
    }
    Else {
		do object.$set("success", 1, "boolean")
	}
   }
 	CATCH ex {
  		Set status = ex.AsStatus()
	}
	if $$$ISERR(status) {
		do object.$set("success", 0, "boolean")
		set object.error = $System.Status.GetErrorText(status)
		set object.data = ##class(%Array).$new()
	}
	write object.$toJSON()
 	&sql(CLOSE c1)
 	Quit $$$OK
}

}

