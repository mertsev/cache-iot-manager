Include %occInclude

Class IOT.Installer
{

/// You can see generated method in zsetup+1^App.Installer.1
XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>
	<IfNotDef Var="Namespace">
		<Var Name="Namespace" Value="mqttiot"/>
		<Log Text="Set namespace to ${Namespace}" Level="0"/>
	</IfNotDef>
    <If Condition='(##class(Config.Namespaces).Exists("${Namespace}")=0)'>
        <Log Text="Creating namespace ${Namespace}" Level="0"/>
        <Namespace Name="${Namespace}" Create="yes" Code="${Namespace}" Ensemble="0" Data="${Namespace}">
            <Configuration>
                <Database Name="${Namespace}" Dir="${MGRDIR}${Namespace}" Create="yes"/>
            </Configuration>
        </Namespace>
        <Log Text="End Creating namespace ${Namespace}" Level="0"/>
    </If>

    <Role Name="AppRole" Description="Role to access and use the App" Resources="%DB_CACHESYS:RW,%Admin_Secure:U" />
    <Namespace Name="${Namespace}" Create="no">
    	<!--<If Condition='(##class(Security.Applications).Exists("/"_"${Namespace}")=0)'>
    	   <Log Text="Creating application" Level="0"/>-->
           <CSPApplication  Url="/mqttrest" Recurse="1" Directory="${CSPDIR}mqttrest" AuthenticationMethods="64" IsNamespaceDefault="true" Grant="AppRole" />
        <!--</If>-->        
        <Log Text="Creating mqttrest app" Level="0"/>
   </Namespace>
   
   <Role Name="AppRole" Description="Role to access and use the App" Resources="%DB_CACHESYS:RW,%Admin_Secure:U" />
    <Namespace Name="${Namespace}" Create="no">
    	<!--<If Condition='(##class(Security.Applications).Exists("/"_"${Namespace}")=0)'>
    	   <Log Text="Creating application" Level="0"/>-->
           <CSPApplication Url="/mqttweb" Recurse="1" Directory="${CSPDIR}mqttweb" AuthenticationMethods="64" IsNamespaceDefault="true" Grant="AppRole" />
        <!--</If>-->        
        <Log Text="Creating mqttweb app" Level="0"/>
   </Namespace>        
</Manifest>
}

}

