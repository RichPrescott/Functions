function Add-Duration {

<#
.SYNOPSIS
Adds durations to an array of objects.

.DESCRIPTION
Takes an array of objects with timestamps and adds duration between each object.

.Parameter Timeline
Specifies the array of objects to add a duration to.

.Parameter TimeColumn
Specifies field containing a timestamp used to determine duration.

.Parameter DurationUnit
Specifies unit of time the duration should be reported in.

.Parameter Integer
Switch to determine if duration reported should be whole numbers or include decimals.

.EXAMPLE
C:\PS>  Get-CMLog -Path C:\ccmeval.log | Add-Duration -DurationUnit Milliseconds | Format-Table DateTime, TotalMilliseconds, Component, Message -AutoSize

DateTime                   TotalMilliseconds Component Message
----                       ----------------- --------- -------
01-21-2016 00:53:51.368    63                CcmEval   MP check succeeded
01-21-2016 00:53:51.431    -                 CcmEval   Send previous report if needed.

.NOTES
Thanks to Nasir Zubair for helping with some performance optimization.

#>

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [PSObject]
        $Timeline,
        $TimeColumn = "DateTime",
        [ValidateSet("Days","Hours","Minutes","Seconds","Milliseconds")]
        $DurationUnit = "Seconds",
        [Switch]
        $Integer
        )

    BEGIN {
        $IsFirstItem = $true
        $PreviousItem = $null
    }

    PROCESS {

        $Timeline | Add-Member -MemberType -NoteProperty -Name "Total$($DurationUnit)" -Value "-" -Force

        if ($IsFirstItem) {
            $IsFirstItem = $false
            $PreviousItem = $Timeline
            return
        }

        Try {
            $TimeSpan = New-TimeSpan -Start ($PreviousItem."$($TimeColumn)") -End ($Timeline."$($TimeColumn)") | Select -ExpandProperty "$Total$($DurationUnit)"

            if ($Integer) {
                $TimeSpan = [int]$TimeSpan
                }
            }
        Catch {
            $TimeSpan = "-"
            }

        $PreviousItem."Total$($DurationUnit)" = $TimeSpan

        Write-Output $PreviousItem

        $PreviousItem = $Timeline
    }

    END {
        # This last item in the list.  As it is the last item, a duration does not exist and will be shown as a dash (-).
        Write-Output $PreviousItem
    }