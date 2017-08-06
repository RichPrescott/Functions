function Get-AOLog
{
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

            Get-Content -Path $File | %{
                $_ -match '(?<Date>\d{4}-\d{2}-\d{2}) (?<Time>\d{2}:\d{2}:\d{2}\,\d{3}) - (?<Level>\w+) - (?<Message>.*) - (?<Component>.*) - TID=(?<TID>\d{1,6}), (?<ThreadDescription>.*)( - )?(?<Misc>.*)?' | Out-Null
                New-Object PSObject -Property @{
                    DateTime = [datetime]::ParseExact($("$($matches.date) $($matches.time)"),"yyyy-MM-dd HH:mm:ss.fff", $null)
                    FileName = $FileName
                    Component = $matches.component
                    Level = $matches.level
                    TID = $matches.TID
                    ThreadDescription = $matches.ThreadDescription
                    Message = $matches.message
                    Misc = $matches.misc
                }
            }
        }
    }
}