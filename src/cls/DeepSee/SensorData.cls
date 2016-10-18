/// 
Class DeepSee.SensorData Extends %DeepSee.CubeDefinition [ DependsOn = Net.MQTT.Storage, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="SensorData" displayName="Sensor Data" disabled="false" abstract="false" sourceClass="Net.MQTT.Storage" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="Devices" disabled="false" hasAll="false" allCaption="All DeviceID" allDisplayName="DeviceID" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="DeviceID" displayName="Device ID" disabled="false" sourceProperty="DeviceID" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
    <additionalDescription>undefined</additionalDescription>
  </dimension>
  <dimension name="Sensors" disabled="false" hasAll="false" allCaption="All SensorType" allDisplayName="SensorType" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="SensorType" displayName="Sensor Type" disabled="false" sourceProperty="SensorType" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
    <additionalDescription>undefined</additionalDescription>
  </dimension>
  <dimension name="SentAt" displayName="Sent At" disabled="false" hasAll="false" allCaption="All CreatedAt" allDisplayName="CreatedAt" sourceProperty="CreatedAt" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="SentAtDate" displayName="Sent at - Date" disabled="false" sourceExpression="$Extract(%source.CreatedAt, 1, 10)" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="SentAtHour" displayName="Sent at - Hour" disabled="false" sourceExpression="$Extract(%source.CreatedAt, 1, 13)" timeFunction="HourNumber" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
        <property name="SentAtHourP" displayName="Sent at - Hour" disabled="false" sourceExpression="$Extract(%source.CreatedAt, 12, 13)" hidden="false" isName="true" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
      </level>
      <level name="SentAtMinute" displayName="Sent at - Minute" disabled="false" sourceExpression="$Extract(%source.CreatedAt, 1, 16)" timeFunction="MinuteNumber" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
        <property name="SentAtMinuteP" displayName="Sent at - Minute" disabled="false" sourceExpression="$Extract(%source.CreatedAt, 12, 16)" hidden="false" isName="true" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
      </level>
      <level name="SentAtSecond" displayName="Sent at - Second" disabled="false" sourceExpression="$Extract(%source.CreatedAt, 1, 19)" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
        <property name="SentAtSecondP" displayName="Sent at - Second" disabled="false" sourceExpression="$Extract(%source.CreatedAt, 12, 19)" hidden="false" isName="true" isDescription="false" isReference="false" useDisplayValue="false">
          <additionalDescription>undefined</additionalDescription>
        </property>
      </level>
    </hierarchy>
    <additionalDescription>undefined</additionalDescription>
  </dimension>
  <measure name="Value" displayName="Sensor Value" disabled="false" sourceProperty="Value1" aggregate="AVG" type="number" hidden="false" searchable="false">
  </measure>
</cube>
}

Parameter DOMAIN;

}

