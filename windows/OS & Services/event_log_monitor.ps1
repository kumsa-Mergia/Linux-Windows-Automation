# ==========================================
# PRODUCTION: Windows Event Log Monitor
# ==========================================

param(
    [string]$LogPath = "C:\Logs\EventLogMonitor.log",
    [int]$LastMinutes = 30
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

Write-Log "========== Event Log Monitoring Started =========="

# Time filter
$StartTime = (Get-Date).AddMinutes(-$LastMinutes)

# Logs to check
$LogNames = @("System", "Application")

$errorsFound = @()

foreach ($logName in $LogNames) {

    Write-Log "Checking log: $logName"

    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName   = $logName
            Level     = 1, 2   # 1=Critical, 2=Error
            StartTime = $StartTime
        } -ErrorAction Stop

        foreach ($event in $events) {
            $msg = "[$logName] ID=$($event.Id) | Source=$($event.ProviderName) | Time=$($event.TimeCreated)"

            Write-Log $msg "ERROR"
            $errorsFound += $msg
        }
    }
    catch {
        Write-Log "Failed to read $logName log: $_" "ERROR"
    }
}

# Summary
Write-Log "========== SUMMARY =========="

if ($errorsFound.Count -eq 0) {
    Write-Log "No critical/errors found in last $LastMinutes minutes"
}
else {
    Write-Log "Total Issues Found: $($errorsFound.Count)"
}

Write-Log "========== Monitoring Completed =========="