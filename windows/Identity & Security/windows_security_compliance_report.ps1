# ============================================
# Windows Security Compliance Report
# ============================================

$Computer = $env:COMPUTERNAME
$Date = Get-Date

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      WINDOWS SECURITY COMPLIANCE REPORT"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Computer : $Computer"
Write-Host "Date     : $Date"
Write-Host ""

# ------------------------------------------------
# Firewall Profiles
# ------------------------------------------------
Write-Host "========== FIREWALL STATUS ==========" -ForegroundColor Yellow

$firewall = Get-NetFirewallProfile | Select Name, Enabled
$firewall | Format-Table -AutoSize

# ------------------------------------------------
# BitLocker Status
# ------------------------------------------------
Write-Host ""
Write-Host "========== BITLOCKER STATUS ==========" -ForegroundColor Yellow

if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {

    Get-BitLockerVolume | Select MountPoint, VolumeStatus, ProtectionStatus | Format-Table -AutoSize

}
else {

    Write-Host "BitLocker feature not available on this system"

}

# ------------------------------------------------
# Local Administrators
# ------------------------------------------------
Write-Host ""
Write-Host "========== LOCAL ADMINISTRATORS ==========" -ForegroundColor Yellow

$admins = Get-LocalGroupMember -Group Administrators | Select Name, ObjectClass
$admins | Format-Table -AutoSize

# ------------------------------------------------
# Listening Ports
# ------------------------------------------------
Write-Host ""
Write-Host "========== LISTENING PORTS ==========" -ForegroundColor Yellow

$ports = Get-NetTCPConnection -State Listen |
Select LocalAddress, LocalPort, OwningProcess

$ports | Sort LocalPort | Format-Table -AutoSize

# ------------------------------------------------
# Windows Defender Status
# ------------------------------------------------
Write-Host ""
Write-Host "========== WINDOWS DEFENDER ==========" -ForegroundColor Yellow

$def = Get-MpComputerStatus

$defStatus = [PSCustomObject]@{
    AntivirusEnabled   = $def.AntivirusEnabled
    RealTimeProtection = $def.RealTimeProtectionEnabled
    AntispywareEnabled = $def.AntispywareEnabled
}

$defStatus | Format-Table -AutoSize


Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Report Completed Successfully"
Write-Host "==========================================" -ForegroundColor Cyan