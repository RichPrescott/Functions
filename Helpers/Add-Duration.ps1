function Add-Duration
{
<#
.SYNOPSIS
Adds durations to an array of objects.

.DESCRIPTION
Takes an array of objects with timestamps and adds duration between each object.

.Parameter Object
Specifies the array of objects to add a duration to.

.Parameter TimeColumn
Specifies field containing a timestamp used to determine duration.

.Parameter Measure
Specifies unit of time the duration should be reported in.

.Parameter Integer
Switch to determine if duration reported should be whole numbers or include decimals.

.EXAMPLE
C:\PS>  Get-CMLog -Path C:\ccmeval.log | Add-Duration -Measure Milliseconds | Format-Table DateTime, TotalMilliseconds, Component, Message -AutoSize

DateTime                   TotalMilliseconds Component Message
----                       ----------------- --------- -------
07-28-2012 15:33:21.368    63                CcmEval   MP check succeeded
01-21-2016 15:33:21.431    -                 CcmEval   Send previous report if needed.

.NOTES
Thanks to Nasir Zubair (@nsr81) for helping with some performance optimization.

#>

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,
                   ValueFromPipeline=$true)]
        [PSObject]
        $Object,
        $TimeProperty = "DateTime",
        [ValidateSet("Days","Hours","Minutes","Seconds","Milliseconds")]
        $Measure = "Seconds",
        [Switch]
        $Integer
    )

    BEGIN
    {
        $IsFirstItem = $true
        $PreviousItem = $null
    }

    PROCESS
    {

        $Object | Add-Member -NotePropertyName "Total$($Measure)" -NotePropertyValue "-" -Force

        if ($IsFirstItem)
        {
            $IsFirstItem = $false
            $PreviousItem = $Object
            return
        }

        Try
        {
            $TimeSpan = New-TimeSpan -Start ($PreviousItem."$($TimeProperty)") -End ($Object."$($TimeProperty)") | Select-Object -ExpandProperty "$Total$($Measure)"

            if ($Integer)
            {
                $TimeSpan = [int]$TimeSpan
            }
        }
        Catch
        {
            $TimeSpan = "-"
        }

        $PreviousItem."Total$($Measure)" = $TimeSpan
        Write-Output $PreviousItem
        $PreviousItem = $Object
    }

    END
    {
        # This last item in the list.  As it is the last item, a duration does not exist and will be shown as a dash (-).
        Write-Output $PreviousItem
    }
}