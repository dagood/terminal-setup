
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

# https://ss64.com/ps/syntax-base36.html
function ConvertTo-Base36
{
    [CmdletBinding()]
    param ([parameter(valuefrompipeline=$true, HelpMessage="Integer number to convert")][int]$decNum="")
    $alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    do
    {
        $remainder = ($decNum % 36)
        $char = $alphabet.substring($remainder,1)
        $base36Num = "$char$base36Num"
        $decNum = ($decNum - $remainder) / 36
    }
    while ($decNum -gt 0)

    $base36Num
}

function ConvertFrom-Base36
{
    [CmdletBinding()]
    param ([parameter(valuefrompipeline=$true, HelpMessage="Alphadecimal string to convert")][string]$base36Num="")
    $alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
    $inputarray = $base36Num.tolower().tochararray()
    [array]::reverse($inputarray)
    [long]$decNum=0
    $pos=0

    foreach ($c in $inputarray)
    {
        $decNum += $alphabet.IndexOf($c) * [long][Math]::Pow(36, $pos)
        $pos++
    }
    $decNum
}

function Redact-History
{
    $history = (Get-PSReadlineOption).HistorySavePath
    $historyBkp = "$history.bak.txt"

    echo "Enter string to redact from $history"
    $s = Read-Host

    if ($s)
    {
        echo "Redacting..."
        # Powershell has the history file open at this point: shuffle it around to get access.
        mv -Force $history $historyBkp
        gc $historyBkp | %{ $_.Replace($s, "******") } | sc $history
        rm $historyBkp
        echo "Done."
    }
}
