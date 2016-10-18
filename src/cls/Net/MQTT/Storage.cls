Class Net.MQTT.Storage Extends (%Persistent, %Populate)
{

Property DeviceID As %String [ Required ];

Property SensorType As %String [ Required ];

Property CreatedAt As %DateTime [ Required ];

Property Value1 As %Numeric [ Required ];

Property Value2 As %Numeric [ Required ];

Property Value3 As %Numeric [ Required ];

Parameter DSTIME = "MANUAL";

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

