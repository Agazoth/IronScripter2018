function Get-UpTime {
    [CmdletBinding()]
    param ([parameter(ValueFromPipeline)][string]$ComputerName,[PSCredential]$Credential,$Authentication)
    $Parameters = @{
        ScriptBlock = [scriptblock]::Create('if($env:OS -match "Windows"){$strBoot = $((systeminfo | find "System Boot Time") -replace "^.+:\s+|,")} else {$strBoot = (who -b) -replace "^\D+"}; Get-Date $strBoot')
    }
    if (!$ComputerName){$ComputerName = hostname}
    if ($Credential){$Parameters.Add('Credential',$Credential);$Parameters.Add('ComputerName',$ComputerName)}
    if ($Authentication){$Parameters.Add('Authentication',$Authentication)}
    $BootDate = icm @Parameters
    [PSCustomObject]@{
        ComputerName = $ComputerName
        LastBootTime = $BootDate
        Uptime = [math]::Round($(New-TimeSpan $BootDate).TotalDays,3)
    }
}