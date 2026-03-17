# ===============================================
# Windows Enterprise Security Audit Script
# ===============================================

$Computer = $env:COMPUTERNAME
$Date = Get-Date

Write-Host "======================================="
Write-Host " WINDOWS ENTERPRISE SECURITY AUDIT"
Write-Host " Computer: $Computer"
Write-Host " Date: $Date"
Write-Host "======================================="


# -----------------------------------
# Firewall Check
# -----------------------------------
Write-Host "`n[Firewall Status]"

$profiles = Get-NetFirewallProfile

foreach ($profile in $profiles) {

    if ($profile.Enabled) {
        Write-Host "[OK] $($profile.Name) Firewall Enabled"
    }
    else {
        Write-Host "[CRITICAL] $($profile.Name) Firewall Disabled"
    }

    if ($profile.DefaultInboundAction -eq "Block") {
        Write-Host "[OK] Inbound Policy Secure"
    }
    else {
        Write-Host "[WARNING] Inbound Policy Not Blocking"
    }

}


# -----------------------------------
# Windows Defender
# -----------------------------------
Write-Host "`n[Windows Defender]"

$def = Get-MpComputerStatus

if ($def.AntivirusEnabled) {
    Write-Host "[OK] Antivirus Enabled"
}
else {
    Write-Host "[CRITICAL] Antivirus Disabled"
}

if ($def.RealTimeProtectionEnabled) {
    Write-Host "[OK] Real-Time Protection Enabled"
}
else {
    Write-Host "[WARNING] Real-Time Protection Disabled"
}


# -----------------------------------
# SMBv1 Check
# -----------------------------------
Write-Host "`n[SMBv1 Protocol]"

$smb = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

if ($smb.State -eq "Disabled") {
    Write-Host "[OK] SMBv1 Disabled"
}
else {
    Write-Host "[CRITICAL] SMBv1 Enabled (Vulnerable)"
}


# -----------------------------------
# Guest Account
# -----------------------------------
Write-Host "`n[Guest Account]"

$guest = Get-LocalUser -Name Guest

if ($guest.Enabled -eq $false) {
    Write-Host "[OK] Guest Account Disabled"
}
else {
    Write-Host "[CRITICAL] Guest Account Enabled"
}


# -----------------------------------
# Local Administrators
# -----------------------------------
Write-Host "`n[Local Administrator Accounts]"

$admins = Get-LocalGroupMember -Group Administrators

foreach ($admin in $admins) {

    Write-Host "[INFO] Admin Account:" $admin.Name
}


# -----------------------------------
# RDP Exposure
# -----------------------------------
Write-Host "`n[RDP Status]"

$rdp = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server"

if ($rdp.fDenyTSConnections -eq 0) {
    Write-Host "[WARNING] RDP Enabled"
}
else {
    Write-Host "[OK] RDP Disabled"
}


# -----------------------------------
# Open Listening Ports
# -----------------------------------
Write-Host "`n[Listening Ports]"

$ports = Get-NetTCPConnection -State Listen

foreach ($p in $ports) {

    $proc = Get-Process -Id $p.OwningProcess -ErrorAction SilentlyContinue

    Write-Host "[PORT]" $p.LocalPort "Process:" $proc.ProcessName
}


# -----------------------------------
# BitLocker Check
# -----------------------------------
Write-Host "`n[BitLocker Status]"

manage-bde -status | Select-String "Protection Status"


Write-Host "`n======================================="
Write-Host " Security Audit Completed"
Write-Host "======================================="