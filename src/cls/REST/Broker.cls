Class REST.Broker Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>

 <Route Url="/test" Method="GET" Call="Test" Cors="true"/>
 
 <Route Url="/json/connect/:ClientID" Method="GET" Call="REST.JSON:GetConnect" Cors="true"/>
 <Route Url="/json/disconnect/:ClientObjectID" Method="GET" Call="REST.JSON:GetDisconnect" Cors="true"/>
 <Route Url="/json/publish/:ClientObjectID" Method="POST" Call="REST.JSON:PostPublish" Cors="true"/>
 <Route Url="/json/subscribe/:ClientObjectID" Method="POST" Call="REST.JSON:PostSubscribe" Cors="true"/>
 <Route Url="/json/unsubscribe/:ClientObjectID" Method="POST" Call="REST.JSON:PostUnsubscribe" Cors="true"/>
 <Route Url="/json/messages/:ClientObjectID" Method="GET" Call="REST.JSON:GetLastMessages" Cors="true"/>
 </Routes>
}

ClassMethod Test() As %Status
{
    &html<Работает!>
    quit $$$OK
}

}

