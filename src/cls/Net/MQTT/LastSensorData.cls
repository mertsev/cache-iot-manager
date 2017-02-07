/// <class>Net.MQTT.LastSensorData</class> saves tha last value of illumination from device
/// Signals send to TopicDevice+"/M"
Class Net.MQTT.LastSensorData Extends %Persistent
{

/// A topic of a device
Property ClientId As %String(MAXLEN = 50) [ Required ];

/// A value of illumination from device
Property SensorValue As %Numeric;

Index ObjKey On ClientId [ IdKey, PrimaryKey, Unique ];

Storage Default
{
<Data name="LastSensorDataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SensorValue</Value>
</Value>
</Data>
<DataLocation>^Net.MQTT.LastSensorDataD</DataLocation>
<DefaultData>LastSensorDataDefaultData</DefaultData>
<IdLocation>^Net.MQTT.LastSensorDataD</IdLocation>
<IndexLocation>^Net.MQTT.LastSensorDataI</IndexLocation>
<StreamLocation>^Net.MQTT.LastSensorDataS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

