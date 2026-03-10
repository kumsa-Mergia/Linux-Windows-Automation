# BitLocker Status Report Script
# Purpose: Checks BitLocker status for all drives

$exportCsv = $true
$csvPath = "$env:USERPROFILE\Desktop\BitLockerStatusReport.csv"

$report = @()

Write-Host "======================================="
Write-Host " BITLOCKER STATUS REPORT"
Write-Host " Computer: $env:COMPUTERNAME"
Write-Host " Date: $(Get-Date)"
Write-Host "======================================="
Write-Host ""

# Check if BitLocker is installed
$bitlockerCmd = Get-Command manage-bde -ErrorAction SilentlyContinue

if (!$bitlockerCmd) {
    Write-Host "BitLocker is NOT installed or supported on this system."
    $report += [PSCustomObject]@{
        Drive  = "N/A"
        Status = "Not Installed"
        Detail = ""
    }
}
else {
    $drives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

    foreach ($drive in $drives) {
        $letter = $drive.DeviceID
        $statusOutput = & manage-bde -status $letter 2>$null
        if ($statusOutput) {
            Write-Host ("Drive " + $letter + ":")
            Write-Host ($statusOutput -join "`n")
            Write-Host ""
            $report += [PSCustomObject]@{
                Drive  = $letter
                Status = "Installed"
                Detail = $statusOutput -join "`n"
            }
        }
        else {
            Write-Host ("Drive " + $letter + ": Error reading BitLocker status")
            $report += [PSCustomObject]@{
                Drive  = $letter
                Status = "Error"
                Detail = ""
            }
        }
    }
}

# Export to CSV
if ($exportCsv) {
    $folder = Split-Path $csvPath
    if (-not (Test-Path $folder)) {
        New-Item -Path $folder -ItemType Directory | Out-Null
    }
    $report | Export-Csv $csvPath -NoTypeInformation -Force
    Write-Host "BitLocker report exported to $csvPath"
}