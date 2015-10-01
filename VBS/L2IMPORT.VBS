'
' L2IMPORT.VBS
'
' Scopo: Copia il contenuto di files CSV del Livello 2 sul
' file server per il caricamento dati nel Data Warehouse
'
' Autori: Manuel Zavatta, Matteo Carlin
'
' Creazione: 21/09/2015
' Aggiornamento: 30/09/2015
'
' Versione: 1.0
'


' definizione variabili, directories e files
Dim log,server_trovato,tentativi,dati,srv,errori,files
log = vbCrLf & "--------------------------------------------------" & vbCrLf & vbCrLf
server_trovato=0
tentativi=5
dati="C:\Progetto\Poli\"
srv="B:\AOD\"
errori=0
files = Array ( "Colata.csv", "Pesi.csv", "Temperature.csv", "Tempi.csv" )


' mappo la share di rete
Set nso = WScript.CreateObject("WScript.Network")
nso.MapNetworkDrive "B:", "\\CASFS\FS1\DWH\IMPORT", False, "CAS\dwhimport", "Aosta2015"


' istanziamento del file system
Set fso = CreateObject("Scripting.FileSystemObject")


' inizio log
log = log & "AVVIO SCRIPT: " & Now() & vbCrLf & vbCrLf


' cicla finche non trova il server
Do While ( server_trovato = 0 )

	' decrementa i tentativi
	tentativi=tentativi - 1
	
	' controlla se trova il server
	If (fso.FolderExists(srv)) Then	
		server_trovato = 1
		Exit Do
	Else
		' logga il tentativo fallito
		log = log & Now() & " Tentativo di connessione al server fallito" & vbCrLf & vbCrLf
	End If
	
	' se i tentativi sono finiti esce dal ciclo
	If ( tentativi = 0 ) Then  
		Exit Do
	End If

	' attende 10 minuti e riprova
	WScript.Sleep 600000
	
Loop


' controlla se il server è stato trovato
If (server_trovato = 1) Then	

	' cicla i files
	For Each file In files
	
		' logga il file
		log = log & "FILE: " & file & " -> "
		
		' chiama la funzione per il file
		'risultato = read_and_write ( dati, srv, file )
		
		' verifica l'exit code
		Select Case risultato
			Case -1
				log = log & "ERR - Server non trovato" & vbCrLf
				errori = 1
			Case -2
				log = log & "ERR - File dei dati non trovato" & vbCrLf
				errori = 1
			Case -3
				log = log & "ERR - File sul server non creato" & vbCrLf
				errori = 1
			Case Else
				log = log & "OK - Righe copiate: " & risultato & vbCrLf
		End Select
		
	Next
	
Else

	' errore server non trovato
	log = log & "Server: " & srv & " non trovato" & vbCrLf
	errori = 1
	
End If


' controlla se si sono verificati errori
If ( errori <> 0 ) Then
	log = log & vbCrLf & "ERR - Si sono verificati errori durante l'importazione" & vbCrLf
Else
	log = log & vbCrLf & "OK - Importazione avvenuta correttamente" & vbCrLf
End If


' fine log
log = log & vbCrLf & "FINE SCRIPT: " & Now() & vbCrLf


' logga i risultati in appending
Set file_log = fso.OpenTextFile("./" & Mid(WScript.ScriptName,1,Len(WScript.ScriptName)-4) & ".LOG", 8, true)
file_log.Write log
file_log.Close
'WScript.Echo log

' smappo la share di rete
nso.RemoveNetworkDrive "B:", True, False


' legge dal file dati locale e scrive nel file server
' exit code:
'	0+ righe scritte
'	-1 server non trovato
'	-2 file dati non trovato
'	-3 file server non creato
Private Function read_and_write ( dati, srv, file )

	Dim contatore_righe,file_creato,riga
	contatore_righe = 0
	file_creato = 0

	Set fso = CreateObject("Scripting.FileSystemObject")

	' controlla se trova il server
	If Not (fso.FolderExists(srv)) Then	
		read_and_write = -1
		Exit Function
	End If
	
	' controlla se il file dati esiste
	If Not (fso.FileExists(dati & file)) Then
		read_and_write = -2
		Exit Function
	End If
   
    ' controlla se non trova il file sul server e lo crea
	If Not (fso.FileExists(srv & file)) Then
		Set file_out = fso.CreateTextFile(srv & file)
		file_out.Close
		file_creato = 1
	End If
	
	' controlla se trova il file sul server
	If Not (fso.FileExists(srv & file)) Then
		read_and_write = -3
		Exit Function
	End If
		
	' blocca del file dati
	Set file_in_lock = fso.OpenTextFile(dati & file, 8)
	' apre il file dati in letture
	Set file_in = fso.OpenTextFile(dati & file, 1)
	' apre il file server in appending
	Set file_out = fso.OpenTextFile(srv & file, 8)

	' cicla tutte le righe del file dati
	Do Until file_in.AtEndOfStream
		' legge la riga
		riga = file_in.ReadLine
		' incrementa il contatore di righe
		contatore_righe = contatore_righe + 1
		' se il file è stato creato o siamo oltre la prima riga la scrive
		If (file_creato = 1 Or contatore_righe > 1) Then
			file_out.Write riga & vbCrlf
		End If
	Loop

	' chiude file dati
	file_in.Close
	' sblocca file dati
	file_in_lock.Close
	' chiude file server
	file_out.Close
	' elimina file locale
	'fso.DeleteFile(dati & file)
	
	' exit code ok
	read_and_write = (contatore_righe - 1)
	
End Function