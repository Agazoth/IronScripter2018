$File = New-Item -ItemType File -Path c:\SpecialFolder\SpecialFile.txt  -Force
$Bill = New-LocalUser "Bill Bennsson" -Password (ConvertTo-SecureString -String BillAdmin -AsPlainText -Force)
$Andy = New-LocalUser "Andy Pandien" -Password (ConvertTo-SecureString -String AndyUser -AsPlainText -Force)
$Access = [System.Security.AccessControl.FileSystemAccessRule]::new($Bill.SID,"Modify","Allow"),[System.Security.AccessControl.FileSystemAccessRule]::new($Andy.SID,"Read","Allow")
$NewACL=[System.Security.AccessControl.DirectorySecurity]::new()
$NewACL.SetSecurityDescriptorSddlForm('D:')
$NewACL.SetAccessRuleProtection($True, $True)
$Access | ForEach-Object {$NewACL.AddAccessRule($_)}
Set-Acl $File.FullName $NewACL