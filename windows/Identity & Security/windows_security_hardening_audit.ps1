Write-Host "========================================"
Write-Host " Windows Security Hardening Audit"
Write-Host "========================================"

# Firewall Status
Write-Host "`n--- Firewall Status ---"
Get-NetFirewallProfile | Format-Table Name, Enabled -AutoSize

# Windows Defender
Write-Host "`n--- Windows Defender Status ---"
$defender = Get-MpComputerStatus
Write-Host "Antivirus Enabled:" $defender.AntivirusEnabled
Write-Host "Real-Time Protection:" $defender.RealTimeProtectionEnabled

# SMBv1 Check
Write-Host "`n--- SMBv1 Status ---"
$smb = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
Write-Host "SMBv1 Enabled:" $smb.State

# Guest Account
Write-Host "`n--- Guest Account ---"
$guest = Get-LocalUser -Name "Guest"
Write-Host "Guest Account Enabled:" $guest.Enabled

# UAC Status
Write-Host "`n--- UAC Status ---"
$uac = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System
Write-Host "UAC Enabled:" $uac.EnableLUA

Write-Host "`nAudit Completed"