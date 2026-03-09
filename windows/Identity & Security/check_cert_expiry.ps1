# Windows Certificate Expiry Monitoring Script
# Author: System Automation Script
# Checks multiple certificate stores for expired or soon-to-expire certificates

$daysWarning = 30
$today = Get-Date

$stores = @(
    "Cert:\LocalMachine\My",
    "Cert:\LocalMachine\WebHosting",
    "Cert:\CurrentUser\My",
    "Cert:\LocalMachine\RemoteDesktop"
)

Write-Host "=============================================="
Write-Host " Windows Certificate Expiration Check"
Write-Host " Server: $env:COMPUTERNAME"
Write-Host " Date: $today"
Write-Host " Warning Threshold: $daysWarning days"
Write-Host "=============================================="
Write-Host ""

foreach ($store in $stores) {

    Write-Host "Checking store: $store"
    Write-Host "--------------------------------"

    $certs = Get-ChildItem $store -ErrorAction SilentlyContinue

    if (!$certs) {
        Write-Host "No certificates found in this store."
        Write-Host ""
        continue
    }

    foreach ($cert in $certs) {

        $expiry = $cert.NotAfter
        $daysLeft = ($expiry - $today).Days

        if ($expiry -lt $today) {

            Write-Host "❌ EXPIRED CERTIFICATE"
            Write-Host "Subject : $($cert.Subject)"
            Write-Host "Expiry  : $expiry"
            Write-Host ""

        }
        elseif ($daysLeft -le $daysWarning) {

            Write-Host "⚠ CERTIFICATE EXPIRING SOON"
            Write-Host "Subject   : $($cert.Subject)"
            Write-Host "Days Left : $daysLeft"
            Write-Host "Expiry    : $expiry"
            Write-Host ""

        }
        else {

            Write-Host "✅ VALID CERTIFICATE"
            Write-Host "Subject : $($cert.Subject)"
            Write-Host "Expiry  : $expiry"
            Write-Host ""

        }

    }

}