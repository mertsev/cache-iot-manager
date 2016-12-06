/// Auxiliary class is used only internally by a <class>Net.MQTT.Client</class> and its <class>Net.MQTT.Agent</class>.
/// <p>Provides the topic list, which the primary content of <b><var>SUBSCRIBE</var></b> and <b><var>UNSUBSCRIBE</var></b> messages.</p>
Class Net.MQTT.Auxiliary.SubscriptionTopic Extends %Persistent
{

Index TopicKey On (Subscription, Topic) [ Unique ];

Relationship Subscription As Net.MQTT.Auxiliary.Subscription [ Cardinality = parent, Inverse = Topics ];

Property Topic As %String(MAXLEN = "") [ Required ];

Property QoSLevel As %Integer(VALUELIST = ",0,1,2") [ InitialExpression = 0 ];

Property GrantedQoS As %Integer(VALUELIST = ",0,1,2");

Storage Default
{
<Data name="SubscriptionTopicDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Topic</Value>
</Value>
<Value name="3">
<Value>QoSLevel</Value>
</Value>
<Value name="4">
<Value>GrantedQoS</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("Topics")</DataLocation>
<DefaultData>SubscriptionTopicDefaultData</DefaultData>
<IdLocation>^Net.MQTT.Auxil93C.SubscriptionC("Topics")</IdLocation>
<IndexLocation>^Net.MQTT.Au93C.Subscriptio1311I</IndexLocation>
<StreamLocation>^Net.MQTT.Au93C.Subscriptio1311S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

