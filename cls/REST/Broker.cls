Class REST.Broker Extends %CSP.REST
{

XData UrlMap
{
<Routes>

 <Route Url="/test" Method="GET" Call="Test"/>
 <Route Url="/json/messages/:Table" Method="GET" Call="REST.JSON:GetAllMessages"/>
 
 
 <Route Url="/json/connect/:ClientID" Method="GET" Call="REST.JSON:GetConnect"/>
 <Route Url="/json/disconnect/:ClientObjectID" Method="GET" Call="REST.JSON:GetDisconnect"/>
 <Route Url="/json/hasmore/:ClientObjectID" Method="GET" Call="REST.JSON:GetHasMore"/>
 <Route Url="/json/lastmessage/" Method="GET" Call="REST.JSON:GetLastMessage"/>
 <Route Url="/json/publish/:ClientObjectID" Method="POST" Call="REST.JSON:PostPublish"/>
 <Route Url="/json/subscribe/:ClientObjectID" Method="POST" Call="REST.JSON:PostSubscribe"/>
 <Route Url="/json/unsubscribe/:ClientObjectID" Method="POST" Call="REST.JSON:PostUnsubscribe"/>
 <Route Url="/json/messages/:ClientObjectID" Method="POST" Call="REST.JSON:PostMessages"/>
 </Routes>
}

ClassMethod Test() As %Status
{
    &html<Работает!>
    quit $$$OK
}

}

