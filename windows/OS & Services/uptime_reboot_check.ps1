# ==========================================
# PRODUCTION: Windows Uptime & Reboot Check
# ==========================================

param(
    [string]$LogPath = "C:\Logs\UptimeReboot.log",
    [string]$CsvPath = "C:\Logs\UptimeReboot.csv",
    [int]$UptimeThresholdHours = 168  # 7 days
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

Write-Log "========== Windows Uptime & Reboot Check Started =========="

# -------------------------------
# 1. Get System Uptime
# -------------------------------
$os = Get-CimInstance Win32_OperatingSystem
$lastBoot = $os.LastBootUpTime
$uptime = (Get-Date) - $lastBoot
$uptimeHours = [math]::Round($uptime.TotalHours, 2)

Write-Log "System Last Boot: $lastBoot"
Write-Log "System Uptime (hours): $uptimeHours"

# -------------------------------
# 2. Check Pending Reboot (Multiple Flags)
# -------------------------------
$rebootRequired = $false
$pendingReasons = @()

# 2.1 Pending Windows Update Reboot
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
    $rebootRequired = $true
    $pendingReasons += "Windows Update Pending Reboot"
}

# 2.2 Pending File Rename Operations
$PendingFileRename = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -ErrorAction SilentlyContinue
if ($PendingFileRename.PendingFileRenameOperations) {
    $rebootRequired = $true
    $pendingReasons += "Pending File Rename Operations"
}

# 2.3 Component-Based Servicing (CBS)
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
    $rebootRequired = $true
    $pendingReasons += "Component Store Pending Reboot"
}

# 2.4 Windows Installer Pending Reboot
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress") {
    $rebootRequired = $true
    $pendingReasons += "Installer Pending"
}

# 2.5 Check if Uptime exceeds threshold
if ($uptimeHours -ge $UptimeThresholdHours) {
    $rebootRequired = $true
    $pendingReasons += "Uptime Exceeded $UptimeThresholdHours hours"
}

# -------------------------------
# 3. Log Results
# -------------------------------
if ($rebootRequired) {
    Write-Log "System requires reboot! Reasons: $($pendingReasons -join ', ')" "WARNING"
}
else {
    Write-Log "System is healthy. No reboot required."
}

# -------------------------------
# 4. Export CSV
# -------------------------------
$csvObj = [PSCustomObject]@{
    ComputerName         = $env:COMPUTERNAME
    LastBoot             = $lastBoot
    UptimeHours          = $uptimeHours
    RebootRequired       = $rebootRequired
    PendingRebootReasons = ($pendingReasons -join '; ')
}

try {
    $csvObj | Export-Csv -Path $CsvPath -NoTypeInformation
    Write-Log "CSV exported: $CsvPath"
}
catch {
    Write-Log "Failed to export CSV: $_" "ERROR"
}

Write-Log "========== Windows Uptime & Reboot Check Completed =========="