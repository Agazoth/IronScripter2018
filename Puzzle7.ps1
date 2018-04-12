class ComputerInfo {
    [string]$ComputerName
    [string]$BIOSManufacturer
    [string]$BIOSVersion
    [string]$Domain
    [int]$Processors
    [int]$Cores
    [int]$TotalPhysicalMemoryGB
    [string]$OSName
    [string]$OSArchitecture
    [string]$Timezone
    [int]$SizeCDriveGB
    [int]$CDriveFreeSpaceGB
    hidden [bool]$LoadAllValues
    hidden [Microsoft.Management.Infrastructure.CimSession]$CimSession

    ComputerInfo() {}
    ComputerInfo([string]$ComputerName, [string]$Domain) {
        $this.ComputerName = $ComputerName
        $this.Domain = $Domain
    }
    LoadCimSession() {
        if (!$this.ComputerName) {$this.ComputerName = hostname}
        try {
            $this.CimSession = New-CimSession -ComputerName $this.ComputerName -ErrorAction Stop
        }
        catch {
            Write-Warning -Message "Cannot find $($this.ComputerName)"
            $this.ComputerName = ''
            break
        }
    }
    LoadComputerData() {
        if (!$this.CimSession) {$this.LoadCimSession()}
        $CimComputer = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $this.CimSession
        if ($CimComputer.Domain -ne $CimComputer.Workgroup) {
            $this.Domain = $CimComputer.Domain
        }
        else {
            $this.Domain = 'Not Domain joined'
        }
    }
    LoadBiosData() {
        if (!$this.CimSession) {$this.LoadCimSession()}
        $CimBios = Get-CimInstance -ClassName Win32_Bios -CimSession $this.CimSession
        $this.BIOSManufacturer = $CimBios.Manufacturer
        $this.BIOSVersion = $CimBios.BIOSVersion -join ';'
    }

    LoadOSData() {
        if (!$this.CimSession) {$this.LoadCimSession()}
        $CimOS = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $this.CimSession
        $this.OSName = $CimOS.Caption
        $this.OSArchitecture = $CimOS.OSArchitecture
    }
    LoadProcessorData() {
        if (!$this.CimSession) {$this.LoadCimSession()}
        $CimProcessor = Get-CimInstance -ClassName Win32_Processor -CimSession $this.CimSession
        $this.Processors = $CimProcessor.NumberOfLogicalProcessors
        $this.Cores = $CimProcessor.NumberOfCores
    }
    LoadMemoryData() {
        if (!$this.CimSession) {$this.LoadCimSession()}
        $this.TotalPhysicalMemoryGB = $(Get-CimInstance -ClassName win32_PhysicalMemory -CimSession $this.CimSession | Measure-Object -Sum Capacity).Sum / 1GB
    }
    LoadTimeZone() {
        if (!$this.CimSession) {$this.LoadCimSession()}
        $this.Timezone = Get-CimInstance -ClassName Win32_TimeZone -CimSession $this.CimSession | Select-Object -ExpandProperty Caption
    }
    LoadDiskData() {
        if (!$this.CimSession) {$this.LoadCimSession()}
        $CimDisk = (Get-CimInstance -ClassName  Win32_LogicalDisk -CimSession $this.CimSession) | Where-Object {$_.DeviceID -eq 'C:'}
        $this.SizeCDriveGB = $CimDisk.size / 1GB
        $this.CDriveFreeSpaceGB = $CimDisk.FreeSpace / 1GB
    }
    [string]GetFreeDiskPctOnC() {
        if (!$this.SizeCDriveGB) {$this.LoadDiskData()}
        return "{0:P}" -f ($this.CDriveFreeSpaceGB / $this.SizeCDriveGB)
    }
    LoadAllObjectValues() {
        $this.LoadCimSession()
        $this.LoadBiosData()
        $this.LoadComputerData()
        $this.LoadDiskData()
        $this.LoadMemoryData()
        $this.LoadOSData()
        $this.LoadProcessorData()
        $this.LoadTimeZone()
    }
    ComputerInfo([string]$ComputerName, [bool]$LoadAllValues) {
        if (($ComputerName -eq '') -or ($ComputerName -eq $null)) {
            throw [InvalidOperationException]::new(
            "ComputerName is empty or null")
            }
        $this.ComputerName = $ComputerName
        $this.LoadAllObjectValues()
    }
}
