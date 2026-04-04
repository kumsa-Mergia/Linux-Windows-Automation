# ==========================================
# PRODUCTION: Startup Program Audit (Fixed)
# ==========================================

param(
    [string]$LogPath = "C:\Logs\StartupAudit.log",
    [string]$CsvPath = "C:\Logs\StartupAudit.csv"
)

# Ensure log directory exists
$logDir = Split-Path $LogPath
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $log = "$timestamp [$Level] $Message"
    Write-Host $log
    Add-Content -Path $LogPath -Value $log
}

Write-Log "========== Startup Program Audit Started =========="

$results = @()

# -------------------------------
# 1. Registry Startup Entries
# -------------------------------
$regPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
)

foreach ($path in $regPaths) {
    if (Test-Path $path) {
        Write-Log "Checking Registry Path: $path"
        $items = Get-ItemProperty -Path $path

        # Filter only actual startup entries
        foreach ($prop in $items.PSObject.Properties | Where-Object {
                $_.MemberType -eq "NoteProperty" -and $_.Name -notmatch "^PS" -and $_.Value
            }) {
            $entry = [PSCustomObject]@{
                Name     = $prop.Name
                Command  = $prop.Value
                Location = $path
                Type     = "Registry"
            }
            $results += $entry
            Write-Log "Found: $($entry.Name) -> $($entry.Command)"
        }
    }
}

# -------------------------------
# 2. Startup Folders
# -------------------------------
$startupPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($path in $startupPaths) {
    if (Test-Path $path) {
        Write-Log "Checking Startup Folder: $path"
        $files = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

        foreach ($file in $files) {
            $entry = [PSCustomObject]@{
                Name     = $file.Name
                Command  = $file.FullName
                Location = $path
                Type     = "StartupFolder"
            }
            $results += $entry
            Write-Log "Found: $($entry.Name)"
        }
    }
}

# -------------------------------
# 3. Smarter Suspicious Detection
# -------------------------------
Write-Log "Running improved suspicious check..."

$SafePaths = @(
    "C:\Windows\System32",
    "C:\Program Files",
    "C:\Program Files (x86)"
)

foreach ($item in $results) {
    $isSafe = $false
    foreach ($safe in $SafePaths) {
        if ($item.Command -like "$safe*") {
            $isSafe = $true
            break
        }
    }
    if (-not $isSafe) {
        Write-Log "WARNING: Suspicious startup entry -> $($item.Name) ($($item.Command))" "WARNING"
    }
}

# -------------------------------
# 4. Export to CSV
# -------------------------------
try {
    $results | Export-Csv -Path $CsvPath -NoTypeInformation
    Write-Log "Results exported to CSV: $CsvPath"
}
catch {
    Write-Log "Failed to export CSV: $_" "ERROR"
}

# -------------------------------
# Summary
# -------------------------------
Write-Log "========== SUMMARY =========="
Write-Log "Total Startup Entries Found: $($results.Count)"
Write-Log "========== Audit Completed =========="