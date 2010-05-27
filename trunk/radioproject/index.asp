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

Set objRS = objConn.Execute("SELECT * FROM t_playlists ORDER BY timestamp DESC limit 20")

Response.Write "<table border='1' cellpadding='1px'>"
While Not objRS.EOF
Response.Write "<tr>"
Response.Write "<td>" & objRS.Fields("bandname") & "</td><td>" & objRS.Fields("songtitle") & "</td><td>" & objRS.Fields("timestamp") & "</td><td>" & objRS.Fields("station")& "</td>"
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