'
' Cryptolock Virus Finder (by Zavy and Matteo)
'
' CRYPTOFINDER.VBS
'
' Scopo: Cerca la chiave di registro del virus Cryptolocker
'
' Utilizzo: /d per visualizzare il dump del risultato
'
' Autori: Manuel Zavatta, Matteo Carlin
'
' Creazione: 24/03/2016
' Aggiornamento: 24/03/2016
'
' Versione: 1.0
'
' ********** set objects
Set objArgs = Wscript.Arguments
Set objShell = CreateObject( "WScript.Shell" )
Set objFs = CreateObject("Scripting.FileSystemObject")
' ********** initialize variables
Dim dump,infected,strMsg,file_log_path
dump = FALSE
infected = FALSE
strMsg = ""
file_log_path="\\repository\DeployInst\log\cryptolocker_finder.zavy"
' ********** check arguments
For Each strArg in objArgs
	if (strArg = "/d") Then
		dump=TRUE
	End If
Next
' ********** resume errors if no dump
if (dump = FALSE) Then
	on error resume next
End If
' ********** Get hostname
strComputer = objShell.ExpandEnvironmentStrings( "%COMPUTERNAME%" )
strMsg = "Host: " & strComputer & vbCrlf
' ********** set registry objects
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set objWbem = GetObject("winmgmts:")
Set objRegistry = GetObject("winmgmts://" & strComputer & "/root/default:StdRegProv")
' ********** Define constants
Const HKEY_USERS = &H80000003
' ********** Check for errors
if err.number <> "-2147217375" then
	' ********** Check to make sure the computer exists on the network.
	Select Case err.number
		Case 462
			strWarn=MsgBox("Unable to connect to " & strComputer & ".", 48, "System Information Checker")
		Case -2147217394
			strWarn=MsgBox(strComputer & " is not a valid name.", 48, "System Information Checker")
		Case 70
			strWarn=MsgBox(strComputer & " has denied access.", 48, "System Information Checker")
    	Case Else
		' ********** Loop through the HKEY_USERS
		lngRtn = objRegistry.EnumKey(HKEY_USERS, "", arrRegKeys)
	
		For Each strKey In arrRegKeys
			If UCase(strKey) <> ".DEFAULT" And UCase(Right(strKey, 8)) <> "_CLASSES" Then
				Set objSID = objWbem.Get("Win32_SID.SID='" & strKey & "'")
				regpath2enumerate = strkey & "\Software"
				objRegistry.enumkey hkey_users, regpath2enumerate, arrkeynames
				If Not (IsEmpty(arrkeynames)) Then
					For Each subkey In arrkeynames
						if(subkey="138BA0329C706166") Then
							infected = TRUE
							strMsg = strMsg & "Virus ID: " & subkey & VbCrLf
						End if
					Next
				End If
			End If
		Next		
	End Select
End If
' ********** Check for errors
strMsg = strMsg & "Infected: " & infected
' ********** Check for dump
if (dump = TRUE) Then
	Wscript.Echo strMsg
End If
' ********** if infected append computer name to log file
if (infected = TRUE) Then
	' apre il file di log in appending
	Set file_log = objFs.OpenTextFile(file_log_path,8,TRUE)
	' scrive nel file di log
	file_log.Write strComputer & vbCrlf
	' chiude file di log
	file_log.Close
End If