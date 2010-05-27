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

objConn.Open(sConnection)

Set objRS = objConn.Execute("SELECT * FROM t_playlists limit 20")


While Not objRS.EOF
Response.Write objRS.Fields("bandname") & ", " & objRS.Fields("songtitle") & ", " & objRS.Fields("timestamp") & ", " & objRS.Fields("station")& "<br>"
Response.Write & " "
objRS.MoveNext
Wend

objRS.Close
Set objRS = Nothing
objConn.Close
Set objConn = Nothing
%>
<br>...Finished
</body>
</html>