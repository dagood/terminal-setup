$psdir="C:\git\terminal-setup\ps\profile\utils"
$toLoad = Get-ChildItem "${psdir}\*.ps1"
$toLoadNames = $toLoad | %{ $_.Name }

$toLoad | %{ Write-Host "Sourcing '$_'"; .$_ } | Out-Null
Write-Host
