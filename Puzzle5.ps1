file:///d%3A/Dokumenter/Scripts/BitBucket/Iron%20Scripter%202018/Puzzle4.ps1
#Pattern

function Get-LegacyCommandObject {
    [CmdletBinding()]
    param ([ValidatePattern("^(netstat|arp)")]
        [string]$CommandLine)
    $Result = iex $CommandLine.split(';',2)[0]
    $Headers = $Result -match '^\w+(`n`r)*'
    
    foreach ($Line in $Result) {
        if ($Line -match '^$'){$Collect = $False;$Properties=$Null;continue}
        if ($Headers -contains $Line){$ObjHash=@{}; if ($Line -match ':'){$Parts = $Line.split(':',2).trim();$ObjHash.add($PArts[0],$Parts[1])};$Collect = $true;$CollectParametersHeader=$true;continue}
        if ($CollectParametersHeader){$Properties = $($Line -split '\s\s+').trim().where{$_ -notmatch '^$'};$CollectParametersHeader=$false;continue}
        if ($Properties){$Values = $($Line -split '\s\s+').trim().where{$_ -notmatch '^$'};for ($i=0; $i -lt $Properties.count;$i++){$ObjHash[$Properties[$i]]=$Values[$i]}}
        [PSCustomObject]$ObjHash
    }
}

