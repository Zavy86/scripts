'
' L2IMPORT.VBS
'
' Scopo: Copia il contenuto di files CSV del Livello 2 sul
' file server per il caricamento dati nel Data Warehouse
'
' Autori: Manuel Zavatta, Matteo Carlin
'
' Creazione: 21/09/2015
' Aggiornamento: 01/10/2015
'
' Versione: 1.0
'


' -------------------- PARAMETRI MODIFICABILI --------------------
Dim dir_script,dir_sorgente,dir_destinazione,files
dir_script = "C:\L2IMPORT\"
dir_sorgente = "C:\DATI\"
dir_destinazione = "AOD\"
files = Array ( "Colata.csv", "Pesi.csv", "Temperature.csv", "Tempi.csv" )
' ------------------ FINE PARAMETRI MODIFICABILI -----------------


' definizione variabili
Dim log,server_trovato,tentativi,errori
log = vbCrLf & "--------------------------------------------------" & vbCrLf & vbCrLf
server_trovato=0
tentativi=5
errori=0


' istanziamento del file system
Set fso = CreateObject("Scripting.FileSystemObject")


' instaziamento della shell
Set sho = WScript.CreateObject("WScript.Shell")


' acquisizione dominio
dominio=sho.Environment("PROCESS").Item("USERDOMAIN")


' modifica della destinazione in base al dominio
If ( dominio = "CAS" ) Then
	dir_destinazione = "\\CASFS\FS1\DWH\IMPORT\" & dir_destinazione
Else
	dir_destinazione = "B:\" & dir_destinazione
End If


' inizio log
log = log & "AVVIO SCRIPT: " & Now() & vbCrLf & vbCrLf


' cicla finche non trova il server
Do While ( server_trovato = 0 )

	' decrementa i tentativi
	tentativi=tentativi - 1
	
	' se la macchina non è in dominio
	If ( dominio <> "CAS" ) Then
		' mappo la share di rete
		On Error Resume Next
		Set nso = WScript.CreateObject("WScript.Network")
		nso.RemoveNetworkDrive "B:", True, False
		Err.Clear
		nso.MapNetworkDrive "B:", "\\192.168.219.115\FS1\DWH\IMPORT", False, "CAS\dwhimport", "Aosta2015"
		If Err.Number <> 0 Then
			' logga il tentativo fallito
			log = log & Now() & " Tentativo di mapping di rete fallito" & vbCrLf & vbCrLf
		End If
		On Error GoTo 0
	End If
	
	' controlla se trova il server
	If (fso.FolderExists(dir_destinazione)) Then	
		server_trovato = 1
		Exit Do
	Else
		' logga il tentativo fallito
		log = log & Now() & " Tentativo di accesso alla direcotry di destinazione fallito" & vbCrLf & vbCrLf
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
		risultato = read_and_write ( dir_sorgente, dir_destinazione, file )
		
		' verifica l'exit code
		Select Case risultato
			Case -1
				log = log & "ERR - Directory destinazione non trovata" & vbCrLf
				errori = 1
			Case -2
				log = log & "ERR - File sorgente non trovato" & vbCrLf
				errori = 1
			Case -3
				log = log & "ERR - File destinazione non creato" & vbCrLf
				errori = 1
			Case Else
				log = log & "OK - Righe copiate: " & risultato & vbCrLf
		End Select
		
	Next
	
Else

	' errore dir_destinazione non trovata
	log = log & "Directory destinazione: " & dir_destinazione & " non trovata" & vbCrLf
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
Set file_log = fso.OpenTextFile(dir_script & Mid(WScript.ScriptName,1,Len(WScript.ScriptName)-4) & ".LOG", 8, true)
file_log.Write log
file_log.Close
'WScript.Echo log


' se la macchina non è in dominio
If ( dominio <> "CAS" ) Then
	' smappo la share di rete
	On Error Resume Next
	nso.RemoveNetworkDrive "B:", True, False
	On Error GoTo 0
End If


' legge dal file dir_sorgente locale e scrive nel file server
' exit code:
'	0+ righe scritte
'	-1 server non trovato
'	-2 file dir_sorgente non trovato
'	-3 file server non creato
Private Function read_and_write ( dir_sorgente, dir_destinazione, file )

	Dim contatore_righe,file_creato,riga
	contatore_righe = 0
	file_creato = 0

	Set fso = CreateObject("Scripting.FileSystemObject")

	' controlla se trova il server
	If Not (fso.FolderExists(dir_destinazione)) Then	
		read_and_write = -1
		Exit Function
	End If
	
	' controlla se il file dir_sorgente esiste
	If Not (fso.FileExists(dir_sorgente & file)) Then
		read_and_write = -2
		Exit Function
	End If
   
    ' controlla se non trova il file sul server e lo crea
	If Not (fso.FileExists(dir_destinazione & file)) Then
		Set file_out = fso.CreateTextFile(dir_destinazione & file)
		file_out.Close
		file_creato = 1
	End If
	
	' controlla se trova il file sul server
	If Not (fso.FileExists(dir_destinazione & file)) Then
		read_and_write = -3
		Exit Function
	End If
		
	' blocca del file dir_sorgente
	Set file_in_lock = fso.OpenTextFile(dir_sorgente & file, 8)
	' apre il file dir_sorgente in letture
	Set file_in = fso.OpenTextFile(dir_sorgente & file, 1)
	' apre il file server in appending
	Set file_out = fso.OpenTextFile(dir_destinazione & file, 8)

	' cicla tutte le righe del file dir_sorgente
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

	' chiude file dir_sorgente
	file_in.Close
	' sblocca file dir_sorgente
	file_in_lock.Close
	' chiude file server
	file_out.Close
	' elimina file locale
	fso.DeleteFile(dir_sorgente & file)
	
	' exit code ok
	read_and_write = (contatore_righe - 1)
	
End Function