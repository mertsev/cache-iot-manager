Class Net.MQTT.BMClient
{

ClassMethod MyMessageHandler(pMessage As Net.MQTT.Message, pTopic As %String) As %Status
{
	try {
	set jstring = pMessage.Content
	set ^msg2($increment(^msg2)) = jstring
	
	set newObject = ##class(%AbstractObject).$fromJSON(jstring)
	
	for i=0:1:(newObject.$size() - 1) 
	{
		set item = newObject.$get(i)
		set s = ##class(Net.MQTT.Storage).%New()
		set s.DeviceID = $Piece(pTopic, "/isctest/client/", 2)
		set s.CreatedAt = item.createdAt
		set s.SensorType = item.name
		set s.Value1 = item.values.$get(0)
		set s.Value2 = item.values.$get(1)
		set s.Value3 = item.values.$get(2)
		set tSC =  s.%Save()
		if $$$ISOK(tSC) {
			do ##class(%DeepSee.Utils).%ProcessFact("SensorData", s.%Id(), 0)
		}
		
	}
	}
	CATCH ex {
		Set tSC = ex.AsStatus()
	}
	quit tSC
}

}

