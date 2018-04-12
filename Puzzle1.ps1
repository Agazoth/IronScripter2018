function Get-MonitorInfo  {
    [CmdletBinding()]
    param ([string[]]$ComputerNames = $env:computername)
    foreach ($ComputerName in $ComputerNames){
        try {
            $CimSession = New-CimSession -ComputerName $ComputerName
        } catch {
            Write-Warning "$Please make sure PSRemoting is enabled on $ComputerName"
            Continue
        }
        
        $Monitors = Get-CimInstance -CimSession $CimSession -Namespace root\wmi -ClassName WmiMonitorID
        $Computer  = Get-CimInstance -CimSession $CimSession -Class Win32_ComputerSystem
        $Bios = Get-CimInstance -CimSession $CimSession -ClassName Win32_Bios
        foreach ($Monitor in $Monitors){
            $PSObject = [PSCustomObject]@{
                ComputerName = $Computer.Name
                ComputerType = $Computer.model
                ComputerSerial = $Bios.SerialNumber
                MonitorSerial = [string]::join('',$monitor.SerialNumberID.Where{$_ -ne 0})
                MonitorType = [string]::join('',$monitor.UserFriendlyName.Where{$_ -ne 0})
            }
            $PSObject
        } 
    }
}

