Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$sp = New-Object -ComObject SAPI.SpVoice
$msgs = @(
    "Catch me!",
    "Too slow!",
    "Quack detected in system32",
    "You have been quacked!",
    "Nice try!",
    "Injecting ducks..."
)

$form = New-Object System.Windows.Forms.Form
$form.Text = "QUACKED"
$form.Size = New-Object System.Drawing.Size(260,140)
$form.StartPosition = "Manual"
$form.TopMost = $true
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.BackColor = [System.Drawing.Color]::Black
$form.KeyPreview = $true   # 🔑 IMPORTANT (captures ESC key)

$label = New-Object System.Windows.Forms.Label
$label.Size = New-Object System.Drawing.Size(220,40)
$label.Location = New-Object System.Drawing.Point(20,15)
$label.ForeColor = [System.Drawing.Color]::White
$label.BackColor = [System.Drawing.Color]::Black
$label.TextAlign = "MiddleCenter"
$label.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
$label.Text = "Try to catch me!"

$button = New-Object System.Windows.Forms.Button
$button.Size = New-Object System.Drawing.Size(100,30)
$button.Location = New-Object System.Drawing.Point(75,65)
$button.Text = "Catch!"

$form.Controls.Add($label)
$form.Controls.Add($button)

function Move-Form {
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $maxX = $screen.Width - $form.Width
    $maxY = $screen.Height - $form.Height

    $form.Left = Get-Random -Minimum 0 -Maximum ($maxX + 1)
    $form.Top  = Get-Random -Minimum 0 -Maximum ($maxY + 1)

    $label.Text = $msgs | Get-Random
}

$action = {
    Move-Form
    $phrase = $msgs | Get-Random
    $label.Text = $phrase
    $sp.Speak($phrase)
}

$button.Add_Click($action)
$form.Add_Click($action)
$label.Add_Click($action)

# 🔑 ESC KEY KILL SWITCH
$form.Add_KeyDown({
    if ($_.KeyCode -eq "Escape") {
        $form.Close()
    }
})

# ⏱ AUTO STOP TIMER
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000

$startTime = Get-Date
$durationSeconds = 25

$timer.Add_Tick({
    if ((New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds -ge $durationSeconds) {
        $timer.Stop()
        $form.Close()
    }
})

Move-Form
$timer.Start()
[void]$form.ShowDialog()
$timer.Dispose()
