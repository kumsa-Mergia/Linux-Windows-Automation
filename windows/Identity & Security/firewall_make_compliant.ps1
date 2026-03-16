# ===============================================
# Windows Firewall Compliance Remediation Script
# Author: System Automation
# ===============================================

$Computer = $env:COMPUTERNAME
$Date = Get-Date

Write-Host "======================================="
Write-Host " Windows Firewall Remediation Script"
Write-Host " Computer: $Computer"
Write-Host " Date: $Date"
Write-Host "======================================="

# Ensure Firewall Service is running
$service = Get-Service mpssvc

if ($service.Status -ne "Running") {
    Write-Host "Starting Windows Firewall Service..."
    Start-Service mpssvc
}
else {
    Write-Host "Firewall Service already running"
}

# Enable Firewall for all profiles
Write-Host ""
Write-Host "Enabling Firewall for Domain, Private, Public..."

Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True

# Set secure inbound policy
Write-Host "Setting inbound policy to BLOCK..."
Set-NetFirewallProfile -Profile Domain, Private, Public -DefaultInboundAction Block

# Set outbound policy
Write-Host "Setting outbound policy to ALLOW..."
Set-NetFirewallProfile -Profile Domain, Private, Public -DefaultOutboundAction Allow

# Enable firewall logging
Write-Host "Enabling Firewall Logging..."
Set-NetFirewallProfile -Profile Domain, Private, Public -LogBlocked True
Set-NetFirewallProfile -Profile Domain, Private, Public -LogAllowed True

Write-Host ""
Write-Host "Firewall configuration is now COMPLIANT"
Write-Host "======================================="