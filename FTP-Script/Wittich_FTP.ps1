<# 
.SYNOPSIS 
    Automatisches hochladen (ftp) an Wittich Verlag  
.DESCRIPTION 
    Generieren der aktuellen Kalenderwoche um das korrekte Verzeichnis aus dem J:\ALLE\PRESSE\HNA-Transfer Pressemitteilungen
    zu ermitteln. Rekursiv Dateien hochladen, dabei die Verzeichnisstruktur beibehalten. 
.NOTES 
    Author     : Christian Grams
.REQUIRE
    WinSCP 5.8.3 (.NET assembly / COM library)
.VERSION
    0.2  

. AENDERUNGEN
    20170102 Jahr und führend "0" eingefügt, [ERFOLG]/[FEHLER] im Betreff der E-Mail eingefügt
                
#> 

net use J: \\s-fs01\daten

$smtpServer = "10.10.20.47"
$smtpPort ="25"
$smtpFrom = "support@fuldatal.de"
$smtpTo = "mon_ftp@fuldatal.de"
$messageSubject2 = "[FEHLER]FTP Uebertragung (Wittich Verlag)"

Set-Location C:\scripts\FTP-Script

#Kalenderwoche finden
function Get-ExtendedDate
{
 $a = get-date
  add-member -MemberType scriptmethod -name GetWeekOfYear -value {get-date -uformat %V} -inputobject $a 
 $a
 }
$a = (Get-ExtendedDate).getWeekofYear()
[int]$b = [convert]::ToInt32($a,10)

#Convert in zweistellige Zahl
$b1 = "{0:00}" -f $b

$c = (Get-Date).Year

$sourcedir = "KW "+$b1+"_"+$c
$source = "J:\ALLE\PRESSE\HNA-Transfer Pressemitteilungen\"+$c+"\"+$sourcedir

$localPaths = $source

$Logfile = "c:\scripts\FTP-Script\KW"+$b1+".log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

LogWrite ("Bearbeiten KW"+$b1)

# WinSCP .NET assembly laden
Add-Type -Path "WinSCPnet.dll"

# Sitzungsoptionen konfigurieren
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Ftp
    HostName = "kundenftp.wittich.de"
    PortNumber = 21
    UserName = "fuldatal"
    Password = "wi-fritz-1329"
}

$session = New-Object WinSCP.Session

try
{
    # Verbinden
    $session.Open($sessionOptions)

        foreach ($localPath in $localPaths)
        {
            # If the selected item is file, find all contained files and folders recursively
            if (Test-Path $localPath -PathType container)
            {
                $files = @($localPath) + (Get-ChildItem $localPath -Recurse | Select-Object -ExpandProperty FullName)
            }
            else
            {
                $files = $localPath
            }
 
            $parentLocalPath = Split-Path -Parent (Resolve-Path $localPath)
 
            foreach ($localFilePath in $files)
            {
                $remoteFilePath = $session.TranslateLocalPathToRemote($localFilePath, $parentLocalPath, $remotePath)
 
                if (Test-Path $localFilePath -PathType container)
                {
                    # Create remote subdirectory, if it does not exist yet
                    if (!($session.FileExists($remoteFilePath)))
                    {
                        $session.CreateDirectory($remoteFilePath)
                    }
                }
                else
                {
                    LogWrite ("Moving file {0} to {1}..." -f $localFilePath, $remoteFilePath)
                    # Upload file and remove original
                    $session.PutFiles($localFilePath, $remoteFilePath).Check()
                }
            }
        }
}
finally
{
    $session.Dispose()
}

# E-Mail senden
Send-MailMessage -From $smtpFrom -To $smtpTo -Subject "[Wittich FTP] Uebertragung KW$b1"  -Body "siehe angehaengte Logdatei" -SmtpServer $smtpServer -Port $smtpPort -Attachments $Logfile

## ..und nun das ganze nochmal für die nächste KW

$b = $b + 1

#Convert in zweistellige Zahl
$b1 = "{0:00}" -f $b

$c = (Get-Date).Year

$sourcedir = "KW "+$b1+"_"+$c
$source = "J:\ALLE\PRESSE\HNA-Transfer Pressemitteilungen\"+$c+"\"+$sourcedir

$localPaths = $source

$Logfile = "c:\scripts\FTP-Script\KW"+$b1+".log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

LogWrite ("Bearbeiten KW"+$b1)

# WinSCP .NET assembly laden
Add-Type -Path "WinSCPnet.dll"

# Sitzungsoptionen konfigurieren
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Ftp
    HostName = "kundenftp.wittich.de"
    PortNumber = 21
    UserName = "fuldatal"
    Password = "wi-fritz-1329"
}

$session = New-Object WinSCP.Session

try
{
    # Verbinden
    $session.Open($sessionOptions)

        foreach ($localPath in $localPaths)
        {
            # If the selected item is file, find all contained files and folders recursively
            if (Test-Path $localPath -PathType container)
            {
                $files = @($localPath) + (Get-ChildItem $localPath -Recurse | Select-Object -ExpandProperty FullName)
            }
            else
            {
                $files = $localPath
            }
 
            $parentLocalPath = Split-Path -Parent (Resolve-Path $localPath)
 
            foreach ($localFilePath in $files)
            {
                $remoteFilePath = $session.TranslateLocalPathToRemote($localFilePath, $parentLocalPath, $remotePath)
 
                if (Test-Path $localFilePath -PathType container)
                {
                    # Create remote subdirectory, if it does not exist yet
                    if (!($session.FileExists($remoteFilePath)))
                    {
                        $session.CreateDirectory($remoteFilePath)
                    }
                }
                else
                {
                    LogWrite ("Moving file {0} to {1}..." -f $localFilePath, $remoteFilePath)
                    # Upload file and remove original
                    $session.PutFiles($localFilePath, $remoteFilePath).Check()
                }
            }
        }
}
finally
{
    $session.Dispose()
}

# E-Mail senden
Send-MailMessage -From $smtpFrom -To $smtpTo -Subject "[Wittich FTP] Uebertragung KW$b1"  -Body "siehe angehaengte Logdatei" -SmtpServer $smtpServer -Port $smtpPort -Attachments $Logfile
