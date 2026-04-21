# Author butlersl
# Combination of:
# cribb-it - Hey!, Got Any Grapes?
# aleff-github - Try_To_Catch_Me

# === Load Required Assemblies ===
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === Initialize Voice ===
$sp = New-Object -ComObject SAPI.SpVoice

# === Messages for Popup ===
$msgs = @(
    "Catch me!",
    "Too slow!",
    "Quack detected in system32",
    "You have been quacked!",
    "Nice try!",
    "Injecting ducks..."
)

# === Audio Setup ===
# Song Credits: https://www.youtube.com/watch?v=MtN1YnoL46Q
$duckSongUrl  = "https://raw.githubusercontent.com/butlersl/305-lab-files/main/Prank/Duck-song.mp3"
$duckSongPath = "$env:TEMP\Duck-song.mp3"
$player = $null

try {
    Invoke-WebRequest -Uri $duckSongUrl -OutFile $duckSongPath -UseBasicParsing
    $player = New-Object -ComObject WMPlayer.OCX
    $player.URL = $duckSongPath
    $player.settings.volume = 100
    $player.controls.play()
} catch {
    # ignore audio failures
}

# === Create Window ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "QUACKED"
$form.Size = New-Object System.Drawing.Size(320,190)
$form.StartPosition = "Manual"
$form.TopMost = $true
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.BackColor = [System.Drawing.Color]::Black
$form.ForeColor = [System.Drawing.Color]::White
$form.KeyPreview = $true

# === Label ===
$label = New-Object System.Windows.Forms.Label
$label.Size = New-Object System.Drawing.Size(260,50)
$label.Location = New-Object System.Drawing.Point(28,22)
$label.ForeColor = [System.Drawing.Color]::White
$label.BackColor = [System.Drawing.Color]::Black
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$label.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
$label.Text = "You have been quacked!"

# === Button ===
$button = New-Object System.Windows.Forms.Button
$button.Size = New-Object System.Drawing.Size(140,42)
$button.Location = New-Object System.Drawing.Point(88,95)
$button.Text = "Catch!"
$button.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
$button.TabStop = $false

$form.Controls.Add($label)
$form.Controls.Add($button)

# === Move Window Function ===
function Move-Form {
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $maxX = [Math]::Max(0, $screen.Width - $form.Width)
    $maxY = [Math]::Max(0, $screen.Height - $form.Height)

    $form.Left = Get-Random -Minimum 0 -Maximum ($maxX + 1)
    $form.Top  = Get-Random -Minimum 0 -Maximum ($maxY + 1)
}

# === Click Behavior ===
$action = {
    $phrase = $msgs | Get-Random
    $label.Text = $phrase
    Move-Form
    try { $sp.Speak($phrase) } catch {}
}

$button.Add_Click($action)
$label.Add_Click($action)
$form.Add_Click($action)

# === ESC to Close ===
$form.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
        $form.Close()
    }
})

# === Cleanup on Close ===
$form.Add_FormClosed({
    try {
        if ($player -ne $null) {
            $player.controls.stop()
            $player.close()
        }
    } catch {}
})

Move-Form
[void]$form.ShowDialog()
