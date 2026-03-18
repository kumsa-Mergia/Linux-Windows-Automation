# ============================================
# Windows Patch / Update Check Script 
# (Check Only)
# ============================================

$Computer = $env:COMPUTERNAME
$Date = Get-Date

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "           WINDOWS PATCH CHECK"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Computer : $Computer"
Write-Host "Date     : $Date"
Write-Host ""

# Installed Updates
Write-Host "========== INSTALLED UPDATES ==========" -ForegroundColor Yellow

try {
    $installedUpdates = Get-HotFix | Select-Object HotFixID, InstalledOn, Description
    if ($installedUpdates.Count -eq 0) {
        Write-Host "No updates found on this system."
    }
    else {
        $installedUpdates | Sort-Object InstalledOn -Descending | Format-Table -AutoSize
    }
}
catch {
    Write-Host "Unable to retrieve installed updates. Try running PowerShell as Administrator."
}

# Pending / Missing Updates (Check Only)
Write-Host ""
Write-Host "========== PENDING / MISSING UPDATES ==========" -ForegroundColor Yellow

if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    Import-Module PSWindowsUpdate
    try {
        $pending = Get-WindowsUpdate -MicrosoftUpdate -IgnoreReboot -AcceptAll -Install:$false
        if ($pending.Count -eq 0) {
            Write-Host "No pending updates. System is up to date." -ForegroundColor Green
        }
        else {
            $pending | Select-Object KB, Size, MsrcSeverity, Title | Format-Table -AutoSize
        }
    }
    catch {
        Write-Host "Error checking pending updates: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "PSWindowsUpdate module is not installed. Cannot check pending updates." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Patch Check Completed"
Write-Host "==========================================" -ForegroundColor Cyan