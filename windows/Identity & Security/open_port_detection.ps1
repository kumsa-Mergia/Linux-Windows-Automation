Write-Host "====== Open Port Detection ======"

$ports = Get-NetTCPConnection -State Listen

foreach ($p in $ports) {

    $process = Get-Process -Id $p.OwningProcess -ErrorAction SilentlyContinue

    Write-Host "Port:" $p.LocalPort "Process:" $process.ProcessName
}