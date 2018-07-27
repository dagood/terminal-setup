
function Diff-Time($a, $b)
{
    $a = Get-Date $a
    $b = Get-Date $b
    $a - $b
}

function ConvertTo-PacificTime($t)
{
    [System.TimeZoneInfo]::ConvertTime(
        (get-date $t),
        (Get-TimeZone 'Pacific Standard Time')
    )
}

function ConvertTo-CentralTime($t)
{
    [System.TimeZoneInfo]::ConvertTime(
        (get-date $t),
        (Get-TimeZone 'Central Standard Time')
    )
}

function ConvertFrom-BuildNumber($num) { $date = (Get-Date '1996-4-1').AddMonths([Math]::Floor($num / 100)); $day = $num % 100; "{0:0000}{1:00}{2:00}" -f $date.Year,$date.Month,$day }
function ConvertFrom-BuildDate($d) { $t = Get-Date '1996-4-1'; $d = $d.ToString(); $d = Get-Date ([string]::Join("", $d[0..3] + "-" + $d[4..5] + "-" + $d[6..7])); (($d.Year - $t.Year) * 12 + $d.Month - $t.Month) * 100 + $d.Day }

function prompt
{
    $wd = pwd
    $Host.UI.RawUI.WindowTitle = "PS: $wd"

    function WriteP($t, $c)
    {
        Write-Host $t -NoNewline -ForegroundColor $c
    }
    WriteP "## $env:UserName" DarkGreen
    WriteP " $wd" Green

    $gitMessage = ""
    $branch = git rev-parse --abbrev-ref HEAD

    if ($LASTEXITCODE -eq 0)
    {
        WriteP " ($branch)" DarkGray
        # Don't do this yet: takes too long.
        #$changes = git status --porcelain
        #if ($changes -ne "")
        #{
            #WriteP "*" Yellow
        #}
    }
    
    WriteP "`n" DarkGreen
    WriteP "#>" DarkGreen
    " "
}
