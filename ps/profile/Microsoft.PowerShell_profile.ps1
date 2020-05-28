# Run 'echo $PROFILE' to find target location for this script.
# For example: C:\Users\dagood\OneDrive - Microsoft\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

$psdir="C:\git\terminal-setup\ps\profile\utils"
$toLoad = Get-ChildItem "${psdir}\*.ps1"
$toLoadNames = $toLoad | %{ $_.Name }

$toLoad | %{ Write-Host "Sourcing '$_'"; .$_ } | Out-Null
Write-Host
