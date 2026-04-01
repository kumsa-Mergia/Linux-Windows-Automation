# ==========================================
# Production-grade NTP Configuration & Sync
# Run With powershell -ExecutionPolicy Bypass -File .\ntp_sync_config.ps1 -NTPServer "10.12.27.11"
# ==========================================
param(
    [string]$NTPServer = "10.12.27.11",
    [string]$LogPath = "C:\Logs\NTPConfigSync.log",
    [string]$CsvPath = "C:\Logs\NTPConfigSync.csv",
    [int]$MaxDriftSeconds = 5,
    [int]$MaxWaitSeconds = 120
)

# Ensure log directory exists
$logDir = Split-Path $LogPath
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $log = "$timestamp [$Level] $Message"
    Write-Host $log
    Add-Content -Path $LogPath -Value $log
}

Write-Log "========== NTP Configuration & Sync Started =========="

# 1. Ensure Windows Time service is running
$w32time = Get-Service w32time -ErrorAction SilentlyContinue
if (-not $w32time) {
    Write-Log "ERROR: Windows Time service not found!" "ERROR"
    exit 1
}

if ($w32time.StartType -ne 'Automatic') {
    Write-Log "Setting Windows Time service startup to Automatic..."
    Set-Service w32time -StartupType Automatic
}

if ($w32time.Status -ne 'Running') {
    Write-Log "Starting Windows Time service..."
    Start-Service w32time
}

# 2. Configure NTP server
Write-Log "Configuring NTP server to $NTPServer..."
w32tm /config /manualpeerlist:$NTPServer /syncfromflags:manual /update | Out-Null

# 3. Restart service safely
Write-Log "Restarting Windows Time service..."
Restart-Service w32time -Force

# 4. Force resync
Write-Log "Forcing time resync..."
try {
    w32tm /resync /nowait | Out-Null
}
catch {
    Write-Log "Resync failed, trying force..."
    w32tm /resync /force | Out-Null
}

# 5. Wait for first successful sync
$elapsed = 0
$interval = 5
$syncConfirmed = $false

while ($elapsed -lt $MaxWaitSeconds -and -not $syncConfirmed) {
    $ntpStatus = w32tm /query /status 2>&1

    # Extract Time Source
    $timeSource = "Unknown"
    if ($ntpStatus -match "Source:\s+(.+)") {
        if ($matches.Count -ge 2) { $timeSource = $matches[1].Trim() }
    }

    # Extract Last Successful Sync Time
    $lastSyncTime = $null
    if ($ntpStatus -match "LastSuccessfulSyncTime:\s+(.+)") {
        if ($matches.Count -ge 2) {
            try { $lastSyncTime = Get-Date $matches[1]; $syncConfirmed = $true } catch { $syncConfirmed = $false }
        }
    }

    if (-not $syncConfirmed) {
        Start-Sleep -Seconds $interval
        $elapsed += $interval
        Write-Log "Waiting for first successful NTP sync..."
    }
}

# 6. Calculate drift
$now = Get-Date
if ($syncConfirmed) {
    $driftSeconds = [math]::Abs(($now - $lastSyncTime).TotalSeconds)
    if ($driftSeconds -le $MaxDriftSeconds) { $syncStatus = "Synchronized" }
    else { $syncStatus = "Out of Sync"; Write-Log "WARNING: Drift $driftSeconds seconds exceeds threshold!" "WARNING" }
}
else {
    $driftSeconds = -1
    $syncStatus = "Out of Sync"
    Write-Log "WARNING: NTP sync not completed within $MaxWaitSeconds seconds!" "WARNING"
}

# 7. Export CSV
$csvObj = [PSCustomObject]@{
    ComputerName = $env:COMPUTERNAME
    TimeService  = (Get-Service w32time).Status
    NTPServer    = $NTPServer
    TimeSource   = $timeSource
    DriftSeconds = $driftSeconds
    SyncStatus   = $syncStatus
    LastSyncRaw  = ($ntpStatus -join " | ")
}

try {
    $csvObj | Export-Csv -Path $CsvPath -NoTypeInformation
    Write-Log "CSV exported: $CsvPath"
}
catch {
    Write-Log "Failed to export CSV: $_" "ERROR"
}

Write-Log "========== NTP Configuration & Sync Completed =========="