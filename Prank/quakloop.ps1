$sp = New-Object -ComObject SAPI.SpVoice
$msgs = @(
    "Catch me!",
    "Too slow!",
    "Quack detected in system32",
    "Injecting ducks...",
    "System fully quacked",
    "You have been quacked."
)

while ($true) {
    $ws = New-Object -ComObject WScript.Shell
    $ws.Popup(($msgs | Get-Random), 2, "QUACKED", 0x0) | Out-Null
    $sp.Speak(($msgs | Get-Random))
    Start-Sleep -Milliseconds 1200
}
