<#
Iron Scripter Prequel Puzzle 2
Remember the following when creating your solution:
• Following your faction’s aims is the most important aspect of this challenge
• Use best practice if it doesn’t conflict with your faction’s aims
• Output a single type of named object – you can assign the name yourself
• Calculate the percentage used space on each disk and add it to the output object
• Create and use a format file or type file as appropriate to control the display of the object you’ll output
• Ensure the code works with remote machines?
• PowerShell v5.1 is the assumed standard for your code. If you can also make the solution work with
PowerShell v6, on Windows, that is a bonus
#>
function Get-WickedOSandDiskObject  {
    param ($ComputerName=$env:COMPUTERNAME)
    $CimSession = New-CimSession -ComputerName $ComputerName
    $ComputerObject = Get-CimInstance Win32_OperatingSystem -CimSession $CimSession | Select-Object *,@{n='Disks';e={Get-CimInstance Win32_LogicalDisk -CimSession $CimSession | Select-Object *,@{n='ProcentageUsed';e={"{0:P}" –f $(($_.size-$_.Freespace)/$_.size)}}}}
    $ComputerObject.psobject.TypeNames.Insert(0, "WickedOSandDiskObject")
    $ComputerObject
}