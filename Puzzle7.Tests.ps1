$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Create a new, unpopulated ComputerInfo object" {
    $ComputerInfo = [ComputerInfo]::new()
    It "Returns a ComputerInfo Class with no properties populated" {
        $ComputerInfo.gettype().Name | Should -Be 'ComputerInfo'
    }
}

Describe "Create a new ComputerInfo with ComputerName and Domain populated" {
    $ComputerInfo = [ComputerInfo]::new('MyMachine','mydomain.com')
    It "Returns a ComputerInfo Class with ComputerName and Domain properties populated"{
        $ComputerInfo.ComputerName | Should -Be 'MyMachine'
        $ComputerInfo.Domain | Should -Be 'mydomain.com'
    }
}

Describe "Load a CimSession on a new ComputerInfo object no ComputerName" {
    $ComputerInfo = [ComputerInfo]::new()
    $ComputerInfo.LoadCimSession()
    It "Returns a ComputerInfo Class with ComputerName and Domain properties populated"{
        $ComputerInfo.ComputerName | Should -Be $env:COMPUTERNAME
        ($ComputerInfo.cimsession).gettype().Name | Should -Be 'CimSession'
    }
}

Describe "Create a new ComputerInfo object with all properties populated" {
    $ComputerInfo = [ComputerInfo]::new($($env:COMPUTERNAME),$true)
    It "Returns a ComputerInfo Class with all 12 properties populated"{
        $ComputerInfo.PSobject.Properties.value.Count | Should -Be 12
        0 | Should -Not -Bein @($ComputerInfo.Processors,$ComputerInfo.Cores,$ComputerInfo.TotalPhysicalMemoryGB,$ComputerInfo.SizeCDriveGB,$ComputerInfo.CDriveFreeSpaceGB)
    }
}

Describe "Create a new ComputerInfo object and populate it with a non-existing computer name" {
    $ComputerInfo = [ComputerInfo]::new("IDoNotExist",$true)
    It "Might just blow up"{
        $ComputerInfo.ComputerName | Should -Be ''
    }
}

Describe "Create a new ComputerInfo object and populate it with a null computer name" {
    It "Might just blow up"{
        {[ComputerInfo]::new($null,$true)} | Should -Throw
    }
}