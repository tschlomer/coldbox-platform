<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>ColdBox Dashboard #getSetting("version")# powered by the ColdBox Framework</title>
</head>


<frameset rows="100,*" framespacing="0" frameborder="no" border="0">
  <frame src="index.cfm?event=#getValue("xehHeader")#" 	scrolling="no" 		noresize="noresize" id="topframe" 	name="topframe" />
  <frame src="index.cfm?event=#getValue("xehHome")#" 	scrolling="auto" 	noresize="noresize" id="mainframe" 	name="mainframe" />
</frameset>


<noframes>
<body>
</body>
</noframes>

</html>
</cfoutput>