# ===============================================
# Windows Firewall Compliance Check Script
# ===============================================

$Computer = $env:COMPUTERNAME
$Date = Get-Date

Write-Host "====================================="
Write-Host " Windows Firewall Compliance Report"
Write-Host " Computer: $Computer"
Write-Host " Date: $Date"
Write-Host "====================================="

$profiles = Get-NetFirewallProfile

foreach ($profile in $profiles) {

    Write-Host ""
    Write-Host "Checking $($profile.Name) Profile"

    # Firewall Enabled Check
    if ($profile.Enabled -eq "True") {
        Write-Host "Firewall Status: ENABLED" -ForegroundColor Green
    }
    else {
        Write-Host "Firewall Status: DISABLED ?" -ForegroundColor Red
    }

    # Default Inbound Action
    if ($profile.DefaultInboundAction -eq "Block") {
        Write-Host "Inbound Policy: Block (Compliant)" -ForegroundColor Green
    }
    else {
        Write-Host "Inbound Policy: NOT Blocking ?" -ForegroundColor Red
    }

    # Default Outbound Action
    if ($profile.DefaultOutboundAction -eq "Allow") {
        Write-Host "Outbound Policy: Allow (Standard)"
    }

    # Logging Check
    if ($profile.LogAllowed -or $profile.LogBlocked) {
        Write-Host "Firewall Logging: Enabled"
    }
    else {
        Write-Host "Firewall Logging: Disabled ?"
    }

    Write-Host "-----------------------------------"
}

Write-Host ""
Write-Host "Compliance Check Completed"