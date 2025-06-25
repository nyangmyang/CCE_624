set sh  = createobject("wscript.shell") 
set oExec = sh.exec ("wmic qfe list") 
wscript.echo " "
do while not oExec.stdout.atendofstream 
	line = oExec.stdout.readline 
	wscript.echo line
loop	


'set sh  = createobject("wscript.shell") 
'set oExec = sh.exec ("wmic product | findstr office") 
'wscript.echo "Product"
'do while not oExec.stdout.atendofstream 
'	line = oExec.stdout.readline 
'	line = trim(mid(line, InStr(line, "  ")+1, Len(line)))
'	line = trim(left(line, InStr(line, "  ")))
'	wscript.echo line
'loop	