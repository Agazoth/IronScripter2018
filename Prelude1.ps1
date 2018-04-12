function Get-RandomString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(3, [int]::MaxValue)]
        [Int]$Length,
        [ValidateRange(1, [int]::MaxValue)]
        [Int]$NonAlphanumericalCharacters
    )
    if ($Length - $NonAlphanumericalCharacters -lt 3) {
        throw "Please make sure that Length is at least 3 larger than NonAlphanumericalCharacters"
    }
    if ($Length + $NonAlphanumericalCharacters -gt [int]::MaxValue) {
        throw "Please make sure that Length and NonAlphanumericalCharacters combined is lower than $([int]::MaxValue)"
    }
    $UpperCaseLetters = $(65..90).foreach{[char]$_}
    $LowerCaseLetters = $(97..122).foreach{[char]$_}
    $Numbers = $(0..9).ForEach{$_}
    $NonAlphanumerical = $((33..47), (58..64), (91..96), (123..126)).foreach{$_.foreach{[char]$_}}
    $Pool = $($UpperCaseLetters, $LowerCaseLetters, $Numbers)
    $Selected = $Pool.foreach{Get-Random -InputObject $_ -Count 1}
    if ($NonAlphanumericalCharacters) {$Selected += Get-Random -InputObject $NonAlphanumerical -Count $NonAlphanumericalCharacters}
    $Selected += Get-Random -InputObject $($Pool.foreach( {$_.foreach{$_}})) -Count $($Length - $Selected.count)
    $(Get-Random -InputObject $Selected -Count ([int]::MaxValue)) -join ''
}