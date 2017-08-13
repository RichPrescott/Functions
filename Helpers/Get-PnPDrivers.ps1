function Get-PnPDrivers
{
    Param(
        $Exclude = 'Generic USB|standard|Microsoft'
    )

    Get-WmiObject -Class Win32_PnPSignedDriver |
    Where-Object {$_.InfName -and $_.Manufacturer -notmatch $Exclude} |
    Sort-Object Manufacturer, DeviceName |
    Select-Object Manufacturer, DeviceName, FriendlyName, InfName, IsSigned, DriverVersion
}