function New-ADOU {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $Name,
        [Parameter(Mandatory=$true)]
        $Description,
        [Parameter(Mandatory=$false)]
        [ValidateScript({Get-ADOrganizationalUnit -Path $_})]
        $Path,
        $StreetAddress,
        $City,
        $State,
        $PostalCode,
        $Country
    )
    If (!$Path){
        $PeoplePath = Get-ADOrganizationalUnit -Filter "Name -like 'People'" | select -expand DistinguishedName
        If (!$PeoplePath){$PeoplePath = (New-ADOrganizationalUnit -Name People -ProtectedFromAccidentalDeletion:$true -PassThru).DistinguishedName}
        $PSBoundParameters.Add('Path',$PeoplePath)
    }
    $PSBoundParameters.Add('ProtectedFromAccidentalDeletion',$true)
    New-ADOrganizationalUnit @PSBoundParameters
}