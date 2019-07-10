function Get-CMLog
{
<#
.SYNOPSIS

Parses logs for System Center Configuration Manager.

.DESCRIPTION

Accepts a single log file or array of log files and parses them into objects.  Shows both UTC and local time for troubleshooting across time zones.

.PARAMETER Path
Specifies the path to a log file or files.

.INPUTS

Path/FullName.  

.OUTPUTS

PSCustomObject.  

.EXAMPLE

C:\PS> Get-CMLog -Path Sample.log

Converts each log line in Sample.log into objects

UTCTime   : 7/15/2013 3:28:08 PM
LocalTime : 7/15/2013 2:28:08 PM
FileName  : sample.log
Component : TSPxe
Context   : 
Type      : 3
TID       : 1040
Reference : libsmsmessaging.cpp:9281
Message   : content location request failed

.EXAMPLE

C:\PS> Get-ChildItem -Path C:\Windows\CCM\Logs | Select-String -Pattern 'failed' | Select -Unique Path | Get-CMLog

Find all log files in folder, create a unique list of files containing the phrase 'failed, and convert the logs into objects

UTCTime   : 7/15/2013 3:28:08 PM
LocalTime : 7/15/2013 2:28:08 PM
FileName  : sample.log
Component : TSPxe
Context   : 
Type      : 3
TID       : 1040
Reference : libsmsmessaging.cpp:9281
Message   : content location request failed

.LINK

http://blog.richprescott.com

#>


    param(
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipelineByPropertyName=$true)]
    [Alias("FullName")]
    $Path
    )

    PROCESS
    {
        foreach ($File in $Path)
        {
            $FileName = Split-Path -Path $File -Leaf

            $oFile = Get-Content -Path $File
            ForEach ($line in $oFile) {
                If ($line.substring(0,7) -eq '<![LOG[') {
                    $line -match '\<\!\[LOG\[(?<Message>.*)?\]LOG\]\!\>\<time=\"(?<Time>.+)(?<TZAdjust>[+|-])(?<TZOffset>\d{2,3})\"\s+date=\"(?<Date>.+)?\"\s+component=\"(?<Component>.+)?\"\s+context="(?<Context>.*)?\"\s+type=\"(?<Type>\d)?\"\s+thread=\"(?<TID>\d+)?\"\s+file=\"(?<Reference>.+)?\"\>' | Out-Null
                }
                Else {
                    $line -match '(?<Message>.*)?  \$\$\<(?<Component>.*)?\>\<(?<Date>.+) (?<Time>.+)(?<TZAdjust>[+|-])(?<TZOffset>\d{2,3})?\>\<thread=(?<TID>.*)\>' | Out-Null
                }
                [pscustomobject]@{
                    UTCTime = [datetime]::ParseExact($("$($matches.date) $($matches.time)$($matches.TZAdjust)$($matches.TZOffset/60)"),"MM-dd-yyyy HH:mm:ss.fffz", $null, "AdjustToUniversal")
                    LocalTime = [datetime]::ParseExact($("$($matches.date) $($matches.time)"),"MM-dd-yyyy HH:mm:ss.fff", $null)
                    FileName = $FileName
                    Component = $matches.component
                    Context = $matches.context
                    Type = $matches.type
                    TID = $matches.TID
                    Reference = $matches.reference
                    Message = $matches.message
                }
            }
        }
    }
}
