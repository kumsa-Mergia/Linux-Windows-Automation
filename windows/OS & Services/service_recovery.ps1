# ==========================================
# PRODUCTION: Restart ONLY Stuck Windows Services
# ==========================================

param(
    [string]$LogPath = "C:\Logs\ServiceRecovery.log",
    [int]$RetryCount = 2,
    [int]$TimeoutSec = 10
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

Write-Log "========== Service Recovery Started =========="

# Critical & sensitive services (DO NOT TOUCH)
$ExcludeServices = @(
    "RpcSs",
    "LSASS",
    "WinDefend",
    "EventLog",
    "RemoteRegistry",
    "sppsvc"
)

# Get ONLY stuck services (NOT normal stopped ones)
$services = Get-WmiObject Win32_Service | Where-Object {
    $_.StartMode -eq "Auto" -and
    $_.Name -notin $ExcludeServices -and
    (
        $_.State -eq "Start Pending" -or
        $_.State -eq "Stop Pending"
    )
}

if (!$services) {
    Write-Log "No stuck services found. System is healthy."
    exit
}

$success = @()
$failed = @()

foreach ($svc in $services) {

    Write-Log "Checking service: $($svc.Name) | State: $($svc.State)"

    $attempt = 0
    $recovered = $false

    while ($attempt -lt $RetryCount -and -not $recovered) {

        $attempt++
        Write-Log "Attempt $attempt for $($svc.Name)"

        try {
            # Kill process ONLY if stuck
            if ($svc.ProcessId -ne 0) {
                Write-Log "Service stuck. Killing PID: $($svc.ProcessId)"
                Stop-Process -Id $svc.ProcessId -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
            }

            # Try to start service
            Start-Service -Name $svc.Name -ErrorAction Stop

            # Wait and verify
            Start-Sleep -Seconds $TimeoutSec

            $check = Get-Service -Name $svc.Name

            if ($check.Status -eq "Running") {
                Write-Log "SUCCESS: $($svc.Name) is running"
                $success += $svc.Name
                $recovered = $true
            }
            else {
                throw "Service not running after restart"
            }
        }
        catch {
            Write-Log "ERROR: $($svc.Name) failed attempt $attempt - $_" "ERROR"
        }
    }

    if (-not $recovered) {
        Write-Log "FAILED: $($svc.Name) could not be recovered" "ERROR"
        $failed += $svc.Name
    }
}

# Summary
Write-Log "========== SUMMARY =========="

Write-Log "Recovered Services: $($success.Count)"
foreach ($s in $success) {
    Write-Log "  [OK] $s"
}

Write-Log "Failed Services: $($failed.Count)"
foreach ($f in $failed) {
    Write-Log "  [FAILED] $f"
}

Write-Log "========== Service Recovery Completed =========="