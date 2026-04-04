# ==========================================
# PRODUCTION: Windows Time Sync Verification
# ==========================================

param(
    [string]$LogPath = "C:\Logs\TimeSyncCheck.log",
    [string]$CsvPath = "C:\Logs\TimeSyncCheck.csv",
    [int]$MaxDriftSeconds = 300  # Maximum allowed drift in seconds (5 minutes)
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

Write-Log "========== Windows Time Sync Verification Started =========="

# -------------------------------
# 1. Get Windows Time Service status
# -------------------------------
$w32Time = Get-Service w32time -ErrorAction SilentlyContinue
if ($w32Time -eq $null) {
    Write-Log "Windows Time service (w32time) not found!" "ERROR"
    exit
}
Write-Log "Windows Time Service status: $($w32Time.Status)"

# -------------------------------
# 2. Get Time Configuration
# -------------------------------
$timeConfig = w32tm /query /configuration 2>&1
$timeSource = w32tm /query /source 2>&1
$lastSync = w32tm /query /status 2>&1

Write-Log "Time Source: $timeSource"

# -------------------------------
# 3. Check System Time Drift
# -------------------------------
try {
    # Compare system time with NTP server
    $ntpTimeRaw = w32tm /stripchart /computer:$timeSource /samples:1 /dataonly 2>&1
    if ($ntpTimeRaw -match "(\-?\d+\.\d+)s") {
        $drift = [math]::Abs([double]$matches[1])
    }
    else {
        $drift = 0
    }
}
catch {
    $drift = -1
    Write-Log "Failed to query NTP drift: $_" "ERROR"
}

if ($drift -ge 0 -and $drift -le $MaxDriftSeconds) {
    Write-Log "Time drift: $drift seconds (within threshold)"
    $syncStatus = "Synchronized"
}
else {
    Write-Log "WARNING: Time drift $drift seconds exceeds threshold ($MaxDriftSeconds)!" "WARNING"
    $syncStatus = "Out of Sync"
}

# -------------------------------
# 4. Export CSV
# -------------------------------
$csvObj = [PSCustomObject]@{
    ComputerName = $env:COMPUTERNAME
    TimeService  = $w32Time.Status
    TimeSource   = $timeSource
    DriftSeconds = $drift
    SyncStatus   = $syncStatus
    LastSyncRaw  = ($lastSync -join " | ")
}

try {
    $csvObj | Export-Csv -Path $CsvPath -NoTypeInformation
    Write-Log "CSV exported: $CsvPath"
}
catch {
    Write-Log "Failed to export CSV: $_" "ERROR"
}

Write-Log "========== Windows Time Sync Verification Completed =========="