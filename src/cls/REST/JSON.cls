Class REST.JSON Extends %Base
{

Parameter TRACETARGET As %String = "^MQTT.Trace";

Parameter ONMESSAGE As %String = "Net.MQTT.BMClient:MyMessageHandler";

ClassMethod GetConnect(ClientID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%DynamicAbstractObject).%FromJSON({"success" : false }.%ToJSON())
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
   If $$$ISOK(status) {
    set status = client.%Save()
   }
   
   // Producement of a JSON (success)
   If $$$ISOK(status) {
	set object.success = 1
	set object.error = ""
	set object.clientObject = client.%Id()
   }
	   }
	   catch ex {
	   set status = ex.AsStatus()	
	   }
	   // Producement of a JSON (fail)
	   if $$$ISERR(status) 
	   {
		   set object.success = 0
		   set object.error = $System.Status.GetErrorText(status)
		   set object.clientObject = ""
		   do client.StartAgent()
  		}
	write object.%ToJSON()
	quit $$$OK
}

ClassMethod GetDisconnect(ClientObjectID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%DynamicAbstractObject).%FromJSON({"success": false}.%ToJSON())
   try { 
   
   // Opening a client from DB and stopping the agent
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .st)
   set status = client.StopAgent()
   // Producement of a JSON (fail)
   If $$$ISERR(status) {
	set object.success = 0
   	Set object.error = $System.Status.GetErrorText(status)
   }
   
   // Deleting a client
   set status = ##class(Net.MQTT.Client).%DeleteId(ClientObjectID)
  
   // Producement of a JSON (success)
   If $$$ISOK(status) {
    set object.success = 1
   }
   		} 
   		catch ex {
	   	set status=ex.AsStatus()
	   	}
	   	// Producement of a JSON (fail)
	   	if $$$ISERR(status) {
  		set object.success = 0
 		Set object.error = $System.Status.GetErrorText(st)
	  	}
	write object.%ToJSON()
	quit $$$OK
}

ClassMethod PostSubscribe(ClientObjectID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%DynamicAbstractObject).%FromJSON({"success": false}.%ToJSON())
   try {
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Opening a client from DB
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .status)
   
   // Producement of a JSON (fail)
   if $$$ISERR(status) {
	   set object.success = 0
	   Set object.error = $System.Status.GetErrorText(status)
	   }
   
   // Defining mqtt message class and list of mqtt objects
   Set tpc = ##class(Net.MQTT.Message).%New()
   Set topics = ##class(%ListOfObjects).%New()
   
   // Creation of an abstract object and a subscription
   set JSON = {}.%FromJSON(obj)
   set iter = JSON.%GetIterator()
   while iter.%GetNext(.key , .value) { 
	   set tpc.Topic = value.topicFilter
	   set tpc.QoSLevel = value.qos
	   Do topics.Insert(tpc)
   }
	set status = client.Subscribe(.topics)
	// Producement of a JSON (fail)
	if $$$ISERR(status) {
	   set object.success = 0
  	   Set object.error = $System.Status.GetErrorText(status)
	}
	
   // Producement of a JSON (success)
   If $$$ISOK(status) {
	   set object.success = 1
   }
   
   
   set arrTopics = []
   for x=1:1:(topics.Count()){
	   set tg = topics.GetAt(x)
	   do arrTopics.%Push({"topicFilter": (tg.Topic), "qos" : (tg.QoSLevel)})
   }
   set object.topics = arrTopics.%ToJSON()
   		} catch ex {
       	set status=ex.AsStatus()
       	}
       	
	   	if $$$ISERR(status) {
		   	
  		// Creation of dynamic object and producement of a JSON (fail)
  		set object.success = 0
  		Set object.error = $System.Status.GetErrorText(status)
		}
	// Producement of a JSON (success)
	write object.%ToJSON()
	quit $$$OK
}

ClassMethod PostUnsubscribe(ClientObjectID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%DynamicAbstractObject).%FromJSON({"success": false}.%ToJSON())
   try { 
   
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   
   // Opening a client from DB
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .status)
   If $$$ISERR(status) {
	set object.success = 0
   	Set object.error = $System.Status.GetErrorText(status)
   }
   
   // Defining mqtt message class and list of mqtt objects
   Set tpc = ##class(Net.MQTT.Message).%New()
   Set topics = ##class(%ListOfObjects).%New()
   
   // Producement of a JSON
   set JSON = ##class(%DynamicAbstractObject).%FromJSON(obj)
   for x=0:1:(JSON.%size()-1){
	   set tpc.Topic = JSON.%get(x).topicFilter
	   Do topics.Insert(tpc)
	   }
	   set status = client.Unsubscribe(.topics)
	   // Producement of a JSON (success)
   		If $$$ISOK(status) {
	   	set object.success = 1
   		}
	   // Producement of a JSON (fail)
	   if $$$ISERR(status) {
		   set object.success = 0
  		Set object.error = $System.Status.GetErrorText(status)
       }
   
  } catch ex {
       set status=ex.AsStatus()
       // Producement of a JSON (fail)
       if $$$ISERR(status) {
  		set object.success = 0
  		Set object.error = $System.Status.GetErrorText(status)
       }
	}
	// Producement of a JSON (success)
	write object.%ToJSON()
	quit $$$OK
}

ClassMethod PostPublish(ClientObjectID As %String) As %Status
{
	set status=$$$OK
	// Definition of dynamic json object
	set object = ##class(%DynamicAbstractObject).%FromJSON({"success": false}.%ToJSON())
   try { 
   
   // Opening a client from DB and publishing a message
   set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .status)
   set ^ERR(20) = ClientObjectID
   // Getting content data
   set obj = %request.Content.Read($$$MaxStringLength)
   // Defining mqtt message class and list of mqtt objects
   Set message = ##class(Net.MQTT.Message).%New()
   // Creation of abstract object and producement of a JSON
   set JSON = ##class(%DynamicAbstractObject).%FromJSON(obj)
	   set message.Topic = JSON.topicName
	   set message.QoSLevel = JSON.qos
	   set message.Retain = JSON.retain
	   set message.Content = JSON.content
	   set status = client.Publish(message)
	   If $$$ISOK(status) {
    	set object.success = 1
    	}
   	} catch ex {
       set status=ex.AsStatus()
       }
	// Producement of a JSON (fail)
    if $$$ISERR(status) {
  	set object.success = 0
  	Set object.error = $System.Status.GetErrorText(status)
  	}
	write object.%ToJSON()
	quit $$$OK
}

ClassMethod GetLastMessages(ClientObjectID As %String) As %Status
{
   set status=$$$OK
   // Definition of dynamic json object
   set object = ##class(%DynamicAbstractObject).%FromJSON({"success" : false }.%ToJSON())
   set queryArray = ##class(%DynamicArray).%New()
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
  	
  	set client = ##class(Net.MQTT.Client).%OpenId(ClientObjectID, -1, .status)
		Set message = ##class(Net.MQTT.Message).%New()
		set message.QoSLevel = 2
  	
  	While $$$ISOK(status) {
	  	&sql(FETCH c1) Quit:SQLCODE
	  	do queryArray.%Push(
	  	{"device" : (device), 
	  	"sensor" : (sensor),
	  	"created" : (created),
	  	"value1" : (value1),
	  	"value2" : (value2),
	  	"value3" : (value3)})
	  	set upLight = $ZCONVERT(sensor, "t")
			if $FIND(upLight, "LIGHT") '= 0 {
	  		
	  	
	  	
			}
 	}
 	
 	If $$$ISOK(status) && $Get(SQLCODE, 0) && (SQLCODE '= 100) {
    	Set status = $$$ERROR($$$SQLError, SQLCODE, "Problem while fetching 'c1'")
    }
    Else {
	    set object.success = 1
	}
   }
 	CATCH ex {
  		Set status = ex.AsStatus()
	}
	if $$$ISERR(status) {
		set object.success = 0
		set object.error = $System.Status.GetErrorText(status)
		set object.data = {}
	}
	write object.%ToJSON()
 	&sql(CLOSE c1)
 	Quit $$$OK
}

}

