Class Net.MQTT.Storage Extends (%Persistent, %Populate)
{

Property DeviceID As %String;

Property SensorType As %String;

Property CreatedAt As %DateTime;

Property Value1 As %Double;

Property Value2 As %Double;

Property Value3 As %Double;

Storage Default
{
<Data name="StorageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DeviceID</Value>
</Value>
<Value name="3">
<Value>SensorType</Value>
</Value>
<Value name="4">
<Value>CreatedAt</Value>
</Value>
<Value name="5">
<Value>Value1</Value>
</Value>
<Value name="6">
<Value>Value2</Value>
</Value>
<Value name="7">
<Value>Value3</Value>
</Value>
</Data>
<DataLocation>^Net.MQTT.StorageD</DataLocation>
<DefaultData>StorageDefaultData</DefaultData>
<IdLocation>^Net.MQTT.StorageD</IdLocation>
<IndexLocation>^Net.MQTT.StorageI</IndexLocation>
<StreamLocation>^Net.MQTT.StorageS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

