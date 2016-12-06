Class Net.MQTT.Delayer Extends %SerialObject
{

Property ActiveDelay As %Float;

Method ActiveDelayGet() As %Float [ ServerOnly = 1 ]
{
	Quit ""
}

Method ActiveDelaySet(Arg As %Float) As %Status [ ServerOnly = 1 ]
{
	Quit $$$OK
}

Property PassiveDelay As %Float;

Method PassiveDelayGet() As %Float [ ServerOnly = 1 ]
{
	Quit ""
}

Method PassiveDelaySet(Arg As %Float) As %Status [ ServerOnly = 1 ]
{
	Quit $$$OK
}

Property IterationCount As %Numeric;

Method IterationCountGet() As %Numeric [ ServerOnly = 1 ]
{
	Quit ""
}

Method IterationCountSet(Arg As %Numeric) As %Status [ ServerOnly = 1 ]
{
	Quit $$$OK
}

Method Delay(HasSignal As %Binary = {TRUE})
{
	if (HasSignal = TRUE) {
		Set ..CurrentIteration = 0
		set ^msg2($increment(^msg2)) = 1
		Hang ..ActiveDelay
	} else {
		Set ..CurrentIteration = ..CurrentIteration + 1
		if (..CurrentIteration = ..IterationCount) {
			Hang ..PassiveDelay
			set ^msg2($increment(^msg2)) = 1
		}
	}
}

Property CurrentIteration As %Numeric;

Storage Default
{
<Data name="DelayerState">
<Value name="1">
<Value>ActiveDelay</Value>
</Value>
<Value name="2">
<Value>PassiveDelay</Value>
</Value>
<Value name="3">
<Value>IterationCount</Value>
</Value>
<Value name="4">
<Value>CurrentIteration</Value>
</Value>
</Data>
<State>DelayerState</State>
<StreamLocation>^Net.MQTT.DelayerS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}

