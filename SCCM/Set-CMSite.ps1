function Set-CMSite
{
    param(
        $SiteCode
    )

    $comSMS = New-Object -ComObject 'Microsoft.SMS.Client'
    $comSMS.SetAssignedSite($SiteCode)
}