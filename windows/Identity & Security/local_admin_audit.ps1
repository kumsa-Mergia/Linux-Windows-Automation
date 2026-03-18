Write-Host "====== Local Administrator Audit ======"

$admins = Get-LocalGroupMember -Group "Administrators"

foreach ($admin in $admins) {
    Write-Host "Admin Account:" $admin.Name
}