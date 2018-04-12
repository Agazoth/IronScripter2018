function Get-Feed  {
    [CmdletBinding()]
    param ($Feeduri = 'https://powershell.org/feed/')
    $c = 0
    $Feeds = Invoke-RestMethod -uri $Feeduri 
    $FeedObjects = foreach ($Feed in $Feeds){
        [PSCustomObject]@{
            'No.' = ++$c
            Title = $Feed.title
            "Publication date" = $Feed.pubDate
            Link = $Feed.link
            Author = $Feed.creator.'#cdata-section'
        }
    }
    $FeedObjects | Format-Table -AutoSize
    while ($FeedObjects.'No.' -notcontains $FeedChoice){$FeedChoice = Read-Host -Prompt 'Select the feed No. you want to read'}
    $FeedObject = $FeedObjects | Where-Object {$_.'No.' -eq $FeedChoice}
    while ($EndpointChoice -notmatch '^(B|C)$') {$EndpointChoice = Read-Host "Display $($Feed.title) in [B]rowser or [C]onsole?"}
    if ($EndpointChoice -eq 'B'){
        Start-Process $FeedObject.Link
    } else {
        Invoke-RestMethod $FeedObject.Link
    }
}

