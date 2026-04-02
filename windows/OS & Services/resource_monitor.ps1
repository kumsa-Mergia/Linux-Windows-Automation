# ==========================================
# PRODUCTION: CPU & Memory Auto-Healing Script
# ==========================================

param(
    [string]$LogPath = "C:\Logs\ResourceMonitor.log",
    [int]$CPUThreshold = 85,
    [int]$MemThreshold = 85,
    [int]$TopProcesses = 5,
    [switch]$KillProcess   # Optional (use carefully)
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

Write-Log "========== Resource Monitoring Started =========="

# Get CPU usage
$cpu = Get-Counter '\Processor(_Total)\% Processor Time'
$cpuUsage = [int]$cpu.CounterSamples.CookedValue

# Get Memory usage
$os = Get-CimInstance Win32_OperatingSystem
$totalMem = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeMem = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedMemPercent = [int]((($totalMem - $freeMem) / $totalMem) * 100)

Write-Log "CPU Usage: $cpuUsage%"
Write-Log "Memory Usage: $usedMemPercent%"

# Check thresholds
if ($cpuUsage -lt $CPUThreshold -and $usedMemPercent -lt $MemThreshold) {
    Write-Log "System resources are within normal limits."
    exit
}

Write-Log "High resource usage detected!" "WARNING"

# Get top processes by CPU
$topCPU = Get-Process | Sort-Object CPU -Descending | Select-Object -First $TopProcesses

Write-Log "Top $TopProcesses CPU-consuming processes:"
foreach ($p in $topCPU) {
    Write-Log "  Name=$($p.ProcessName) | CPU=$([int]$p.CPU)"
}

# Get top processes by Memory
$topMem = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First $TopProcesses

Write-Log "Top $TopProcesses Memory-consuming processes:"
foreach ($p in $topMem) {
    $memMB = [math]::Round($p.WorkingSet / 1MB, 2)
    Write-Log "  Name=$($p.ProcessName) | Memory=${memMB}MB"
}

# Optional remediation (SAFE MODE)
if ($KillProcess) {

    Write-Log "KillProcess flag is ENABLED - attempting remediation" "WARNING"

    foreach ($proc in $topCPU) {

        # Skip critical system processes
        if ($proc.ProcessName -in @("System", "Idle", "svchost", "lsass")) {
            continue
        }

        try {
            Write-Log "Stopping process: $($proc.ProcessName) (PID: $($proc.Id))"
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            Write-Log "Stopped: $($proc.ProcessName)"
        }
        catch {
            Write-Log "Failed to stop: $($proc.ProcessName) - $_" "ERROR"
        }
    }
}

Write-Log "========== Monitoring Completed =========="