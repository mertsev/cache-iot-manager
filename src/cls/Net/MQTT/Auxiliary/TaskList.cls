/// Auxiliary class is used only internally, which proides an event-drivn interface for a <class>Net.MQTT.Client</class> and its <class>Net.MQTT.Agent</class>.
Class Net.MQTT.Auxiliary.TaskList Extends %Persistent
{

/// <property>connectionId</property> property of the corresponding <class>Net.MQTT.Client</class> and <class>Net.MQTT.Agent</class> objects.
Property ConnectionId As %String [ Required ];

/// Task-dependent context identifier. The cretor and processor of the task must agree on the meaning of this string. 
Property ContextId As %String(MAXLEN = "") [ Required ];

/// List of actions, which require an event-driven interface.
Property Action As %String(VALUELIST = ",DISCONNECT,SUBSCRIBE,UNSUBSCRIBE,PUBLISH,PUBACK,PUBREC,PUBREL,PUBCOMP") [ Required ];

/// Current status of the task:<ul>
/// <li><b><var>0</var></b> - <b><var>Pending</var></b>, waiting for being processed.</li>
/// <li><b><var>1</var></b> - <b><var>In progress</var></b>, the <class>Net.MQTT.Agent</class> already picked up the task.</li>
/// <li><b><var>2</var></b> - <b><var>Done</var></b>, and kept for debugging purposes.</li>
/// </ul>
Property Status As %Integer(MAXVAL = 2, MINVAL = 0) [ InitialExpression = 0, Required ];

/// Called when a particular message (identified by <var>pMessageId</var>) of a client connection is waiting for an event.
/// <p>The <class>%SYSTEM.Event</class> API is used to implement this, for detailed explanation of the return value, see that class documentation!</p>
ClassMethod WaitAck(pConnectionId As %String, pMessageId As %String, pStatus As %String, pTimeout As %Integer = -1) As %List
{
	Set ret = ""
	Do $System.Event.Create("^MQTT.Message(""" _ pConnectionId _ """,""" _ pMessageId _ """,""" _ pStatus _ """)")
	Set ret = $System.Event.WaitMsg("^MQTT.Message(""" _ pConnectionId _ """,""" _ pMessageId _ """,""" _ pStatus _ """)", pTimeout)
	
	Quit ret
}

/// Called to trigger an event of a particular message (identified by <var>pMessageId</var>) of a client connection.
/// <p>The <class>%SYSTEM.Event</class> API is used to implement this, for detailed explanation of the return value, see that class documentation!</p>
ClassMethod SignalAck(pConnectionId As %String, pMessageId As %String, pStatus As %String, pContent As %String = "") As %Integer
{
	Do $System.Event.Create("^MQTT.Message(""" _ pConnectionId _ """,""" _ pMessageId _ """,""" _ pStatus _ """)")
	Quit $System.Event.Signal("^MQTT.Message(""" _ pConnectionId _ """,""" _ pMessageId _ """,""" _ pStatus _ """)", pContent)
}

/// Creates a task and waits until it will be completed.
/// <p>The <class>%SYSTEM.Event</class> API is used to implement this, for detailed explanation of the return value, see that class documentation!</p>
ClassMethod WaitTask(pConnectionId As %String, pContextId As %String, pAction As %String, pTimeout As %Integer = -1, ByRef pSC As %Status) As %List
{
	Set ret = ""
	Set taskId = ..CreateNewTask(pConnectionId, pContextId, pAction, .pSC)
	If $$$ISOK(pSC) {
		Do $System.Event.Create("^MQTT.Task(""" _ pConnectionId _ """,""" _ taskId _ """)")
		Set ret = $System.Event.WaitMsg("^MQTT.Task(""" _ pConnectionId _ """,""" _taskId _ """)", pTimeout)
	}
	
	Quit ret
}

/// Signals the completion of a task.
/// <p><var>pStatusCode</p> is the return status of the method, which processed the task.</p>
/// <p><var>pDebugMode</p> shows, whether the <class>Net.MQTT.Auxiliary.TaskList</class> object has to be kept for debugging purposes,
///  or can be deleted.</p>
ClassMethod SignalTask(pConnectionId As %String, pTaskId As %String, pStatusCode As %Status, pDebugMode As %Boolean = 0) As %Status
{
	Do $System.Event.Signal("^MQTT.Task(""" _ pConnectionId _ """,""" _ pTaskId _ """)", $Select($$$ISOK(pStatusCode): "", 1: $System.Status.GetErrorText(pStatusCode)))
	Set tSC = ..CompleteTask(pTaskId, pDebugMode)
	
	Quit tSC
}

ClassMethod CreateNewTask(pConnectionId As %String, pContextId As %String, pAction As %String, ByRef pSC As %Status) As %String
{
	Set obj = ..%New()
	Set obj.ConnectionId = pConnectionId
	Set obj.ContextId = pContextId
	Set obj.Action = pAction
	Set pSC = obj.%Save()
	Quit $Select($$$ISOK(pSC): obj.%Id(), 1: "")
}

ClassMethod AcquireNext(pConnectionId As %String, Output pTaskId As %String, Output pContextId As %String, Output pAction As %String) As %Status
{
	Set tSC = $$$OK
	Set (pTaskId, pContextId, pAction) = ""
	Lock +^Net.MQTT.Auxiliary.TaskListD:5 Quit:('$Test) $$$ERROR($$$GeneralError, "Task table lock failed")
	TRY {
		&sql(SELECT TOP 1 
			ID, ContextId, Action 
		INTO 
			:pTaskId, :pContextId, :pAction
		FROM
			Net_MQTT_Auxiliary.TaskList
		WHERE
			ConnectionId = :pConnectionId AND Status = 0
		)
		If $Get(SQLCODE, 0) {
			If (SQLCODE '= 100) {
				Set tSC = $$$ERROR($$$GeneralError, "Task table query failed (" _ SQLCODE _ ")")
			}
		}
		Else {
			Set tSC = ..AcquireTask(pTaskId)
		}
	}
	CATCH ex {
		Set tSC = ex.AsStatus()
	}
	Lock -^Net.MQTT.Auxiliary.TaskListD
	
	Quit tSC
}

ClassMethod AcquireTask(pTaskId As %String) As %Status
{
	Set obj = ..%OpenId(pTaskId, 4)
	If $IsObject(obj) {
		Set obj.Status = 1
		Set tSC = obj.%Save()
	}
	Else {
		Set tSC = $$$ERROR($$$GeneralError, "Task cannot be found (id = " _ pTaskId _ ")")
	}
	
	Quit tSC
}

ClassMethod CompleteTask(pTaskId As %String, pKeepIt As %Boolean = 0) As %Status
{
	Set tSC = $$$OK, found = 0
	If pKeepIt {
		Set obj = ..%OpenId(pTaskId, 4)
		If $IsObject(obj) {
			Set found = 1
			Set obj.Status = 2
			Set tSC = obj.%Save()
		}
	}
	Else {
		Set found = $$$ISOK(..%DeleteId(pTaskId, 4))
	}

	If 'found {
		Set tSC = $$$ERROR($$$GeneralError, "Task cannot be found (id = " _ pTaskId _ ")")
	}
	
	Quit tSC
}

Storage Default
{
<Data name="TaskListDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ConnectionId</Value>
</Value>
<Value name="3">
<Value>ContextId</Value>
</Value>
<Value name="4">
<Value>Action</Value>
</Value>
<Value name="5">
<Value>Status</Value>
</Value>
</Data>
<DataLocation>^Net.MQTT.Auxiliary.TaskListD</DataLocation>
<DefaultData>TaskListDefaultData</DefaultData>
<IdLocation>^Net.MQTT.Auxiliary.TaskListD</IdLocation>
<IndexLocation>^Net.MQTT.Auxiliary.TaskListI</IndexLocation>
<StreamLocation>^Net.MQTT.Auxiliary.TaskListS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

