Write-Host "====== RDP Security Check ======"

$rdp = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server"

if ($rdp.fDenyTSConnections -eq 0) {
    Write-Host "RDP is ENABLED"
}
else {
    Write-Host "RDP is DISABLED"
}

Write-Host "`nRDP Port:"
Get-ItemProperty `
    "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" |
Select PortNumber