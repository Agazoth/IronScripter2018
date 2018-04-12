$ScheduledJobName = "CleanupTempFolder"
$ScriptBlock = [ScriptBlock]::Create(@'
[System.IO.FileInfo]$LogFile = "C:\Logs\CleanTempLog.log"
if (!$(Test-Path $LogFile.DirectoryName)){New-Item -ItemType Directory -Path $LogFile.DirectoryName}
function Get-TempFileObject {
    param ($Timing)
    $TempContent = Get-ChildItem $env:temp -Recurse -Force
    [PSCustomObject]@{
            Filecount = ($TempContent | Where-Object {!$_.psiscontainer}).Count
            Foldercount=($TempContent | Where-Object {$_.psiscontainer}).Count
            TotalSizeMB=[math]::round($($TempContent | Measure-Object -Property length -Sum).Sum/1MB,2)
            TempContent=$TempContent
            TimeStamp = Get-Date
            Timing=$Timing
    }
}
$TempObject = Get-TempFileObject -Timing Before
$TempObject | Select-Object * -ExcludeProperty TempContent | export-csv $LogFile -Append -NoTypeInformation
Clear-RecycleBin -DriveLetter (get-item $env:temp).PSDrive -Force
$TempObject.TempContent.foreach{try{if($_.exists -and $_.CreationTime -lt (get-date).adddays(-1)){$_.delete()}} catch{}}
Get-TempFileObject -Timing After | Select-Object * -ExcludeProperty TempContent | export-csv $LogFile -Append -NoTypeInformation
'@)
if (!$(Get-ScheduledJob $ScheduledJobName -ErrorAction SilentlyContinue)){
    Register-ScheduledJob -Name $ScheduledJobName -Trigger @{Frequency="Daily"; At="9:00 AM"} -ScriptBlock $ScriptBlock -ScheduledJobOption -ScheduledJobOption WakeToRun -RunNow
}
