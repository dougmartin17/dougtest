<html>
<head>
<title>Simple Database report</title>
</head>
<body>
Start...<br>
<%
dim todaysDate
todaysDate=now()
Response.write todaysDate
%>
<%
Dim sConnection, objConn , objRS

sConnection = "DRIVER={MySQL ODBC 3.51 Driver}; SERVER=localhost; DATABASE=playlistproject; UID=root;PASSWORD=black; OPTION=3"

Set objConn = Server.CreateObject("ADODB.Connection")

objConn.Open("DSN=mysql_dsn")

Response.Write "<h3>Last 20 songs recorded</h3>"
Set objRS = objConn.Execute("SELECT * FROM t_playlists ORDER BY timestamp DESC limit 20")

Response.Write "<table border='1'>"
While Not objRS.EOF
Response.Write "<tr>"
Response.Write "<td>" & objRS.Fields("bandname") & "</td><td>" & objRS.Fields("songtitle") & "</td><td>" & objRS.Fields("timestamp") & "</td><td>" & objRS.Fields("station")& "</td>"
Response.Write "</tr>"
objRS.MoveNext
Wend

Response.Write "</table>"

dim startdate, enddate
startdate = Year(Now()) & "-" & Month(Now()) & "-" & Day(Now())
dim tomorrowsDate
tomorrowsDate = DateAdd("d",1,Now())
enddate = Year(tomorrowsDate) & "-" & Month(tomorrowsDate) & "-" & Day(tomorrowsDate)

dim top20sql
top20sql = "select bandname,count(bandname) as bandcount from t_playlists where timestamp>'" & startdate & "' and timestamp<'" & enddate & "' group by bandname order by bandcount desc limit 20"
Set objRS = objConn.Execute(top20sql)
Response.Write "<h3>Top 20 bands today</h3>"
Response.Write "<table border='1'>"
While Not objRS.EOF
Response.Write "<tr>"
Response.Write "<td>" & objRS.Fields("bandname") & "</td><td>" & objRS.Fields("bandcount") & "</td>"
Response.Write "</tr>"
objRS.MoveNext
Wend

Response.Write "</table>"

objRS.Close
Set objRS = Nothing
objConn.Close
Set objConn = Nothing
%>
<br>...Finished
</body>
</html>

select bandname,count(bandname) as bandcount from t_playlists group by bandname order by bandcount desc where limit 20;