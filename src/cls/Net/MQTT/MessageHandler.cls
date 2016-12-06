Class Net.MQTT.MessageHandler [ Abstract ]
{

/// Sample implementation of a message handler method, which is called by the <class>Net.MQTT.Agent</class> everytime, when it receives
/// a new incoming message.
/// 
/// The name of this class and method have to be set in the <property>OnMessage</property> property of the <class>Net.MQTT.Client</class> object.
ClassMethod OnMessage(ByRef pMessage As Net.MQTT.Message, pDublicate As %Boolean) As %Status
{
	Set msg				= ##class(Net.MQTT.MessageStore).%New()
	Set msg.ClientId	= pMessage.ClientId
	Set msg.Direction	= "I"
	Set msg.MessageId	= pMessage.MessageId
	Set msg.QoSLevel	= pMessage.QoSLevel
	Set msg.Retain		= pMessage.Retain
	Set msg.Topic		= pMessage.Topic
	Set msg.Content		= pMessage.Content

	Quit msg.%Save()
}

}

