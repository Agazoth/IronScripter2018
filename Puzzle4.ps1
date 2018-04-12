file:///d%3A/Dokumenter/Scripts/BitBucket/Iron%20Scripter%202018/Puzzle5.ps1
function Get-CounterReport  {
    [CmdletBinding()]
    param ($ComputerName=$env:COMPUTERNAME,
        [system.io.fileinfo]$ExportCliXML,
        [switch]$OutHTML,
        [switch]$Quiet)
    $OutputObject = [ordered]@{CollectionDate = $(Get-Date);ComputerName = $ComputerName}
    $Parameters = @{ComputerName = $ComputerName}
    Write-Verbose "Fetching Processor Time on $ComputerName"
    $Parameters["Counter"] = "\\{0}\Processor(_Total)\% Processor Time" -f $ComputerName
    $OutputObject['PercentageProcessorTime'] = (Get-Counter @Parameters -SampleInterval 2 -MaxSamples 3).countersamples.CookedValue | measure-object -Average | select -ExpandProperty Average
    Write-Verbose "Fetching Free Space on C: on $ComputerName"
    $Parameters["Counter"] = "\\{0}\LogicalDisk(c:)\% Free Space" -f $ComputerName
    $OutputObject['PercentageFreespaceC'] = (Get-Counter @Parameters -MaxSamples 1).countersamples.CookedValue 
    Write-Verbose "Fetching Memory % comitted byte on $ComputerName"
    $Parameters["Counter"] = "\\{0}\Memory\% Committed Bytes In Use" -f $ComputerName
    $OutputObject['PctCommittedBytes'] = (Get-Counter @Parameters -MaxSamples 1).countersamples.CookedValue 
    Write-Verbose "Fetching Network usage on physical network adapters (busiest 2) on $ComputerName"
    $Adapters = (Get-NetAdapter -Physical).where{$_.MediaType -notmatch '802.11'}
    $str="ProductName='" + ($Adapters.InterfaceDescription -join "' or ProductName='") +"'"
    $NetCardNames = Get-WmiObject win32_networkadapter -Filter $str | select -ExpandProperty Name
    $CardSamples = Foreach ($NetCardName in $NetCardNames){
        $Parameters["Counter"] = '\\{0}\Network Interface({1})\Bytes Total/sec' -f $ComputerName,$NetCardName
        Get-Counter @Parameters -MaxSamples 1
    }
    $i=1
    $CardSamples | sort CookedValue -Descending | select -first 2 | foreach {
        $OutputObject[$('Network{0}BytesPrSecond' -f $i)] = $_.countersamples.CookedValue
        $i++ 
    }
    if ($OutHTML){[PSCustomObject]$OutputObject | ConvertTo-Html | Out-file $env:TEMP\Stats.html;iex $env:TEMP\Stats.html}
    if ($ExportCliXML -and $(test-path $ExportCliXML.Directory)){Export-Clixml -InputObject $([PSCustomObject]$OutputObject) -Path $ExportCliXML.Fullname}
    if (!$Quiet){[PSCustomObject]$OutputObject}
}