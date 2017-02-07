/// <class>Net.MQTT.BMClient</class> make a callback for android application. It handle light data signals from
/// android device and send a response for it. It has three types of response: <ul>
/// <li>Low light - if the environment has a low illumination</li>
/// <li>Medium light - if the environment has a medium illumination</li>
/// <li>High light - if the environment has a high illumination</li>
/// </ul>
/// Signals send to TopicDevice+"/M"
Class Net.MQTT.BMClient Extends %RegisteredObject
{

/// This is a callback himself. 
/// Arguments: <ul>
/// <li>pMessage - a message that was received from device</li>
/// <li>pTopic - device identifier, a topic of message</li>
/// <li>pClientObj - reference to Client object, that will receive/send a message from/to device</li>
/// </ul>
ClassMethod MyMessageHandler(pMessage As Net.MQTT.Message, pTopic As %String, pClientObj As Net.MQTT.Client) As %Status
{
	try {
		set jstring = pMessage.Content
		
		set newObject = ##class(%DynamicAbstractObject).%FromJSON(jstring)
		
		for i=0:1:(newObject.%Size() - 1) 
		{
			set item = newObject.%Get(i)
			set s = ##class(Net.MQTT.Storage).%New()
			set s.DeviceID = $Piece(pTopic, "/isctest/client/", 2)
			set s.CreatedAt = $ZDateTime($ZTimestamp, 3)
			set s.SensorType = item.name
			set s.Value1 = item.values.%Get(0)
			set s.Value2 = item.values.%Get(1)
			set s.Value3 = item.values.%Get(2)
			
			set slight = $ZCONVERT(s.SensorType, "L")
			if $FIND(slight, "light") {
				d ..sendToPhone(pTopic, s.Value1, pClientObj)
			}
				
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

/// Method that send a response signal to 
/// Arguments: <ul>
/// <li>pTopic - device identifier, a topic of message</li>
/// <li>value - the degree of illumination of the environment in Lux</li>
/// <li>pClientObj - reference to Client object, that will receive/send a message from/to device</li>
/// </ul>
ClassMethod sendToPhone(pTopic, value, pClientObj As Net.MQTT.Client) As %Status
{
	
	&sql(SELECT SensorValue INTO :sensorValue 
		FROM Net_MQTT.LastSensorData WHERE ClientId = :pTopic)
	
	Set answer = value / 1000.0 * 255
	if answer < 10 {
		set answer = 10
	}
	
	if answer > 255 {
		set answer = 255
	}
	
	
	&sql(INSERT OR UPDATE INTO Net_MQTT.LastSensorData
		SET ClientId = :pTopic, SensorValue = :value)
	
	Set message = ##class(Net.MQTT.Message).%New()
	Set message.Topic = pTopic _ "/M"
	Set message.Content = answer
	Set message.QoSLevel = 2
	Set message.Retain = 1
	try {
	Set sc = pClientObj.Publish(message) 
	} catch ex{
	}

	Set client2 = ##class(Net.MQTT.Client).%New()
	Set client2.Host = "iot.eclipse.org"
	Set client2.ClientId = "My1stMQTTClient2"
	Set client2.traceTarget = "^MQTT.Trace"
	Set sc = client2.StartAgent() If ('sc) { Do $System.OBJ.DisplayError(sc) }
	Set sc = client2.Publish(message) If ('sc) { Do $System.OBJ.DisplayError(sc) }
	Set sc = client2.StopAgent() If ('sc) { Do $System.OBJ.DisplayError(sc) }
}

}

