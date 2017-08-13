function Out-ConsoleGraph {

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,
                   ValueFromPipeline=$true)]
        [Object]
        $Object,
        [Parameter(Mandatory=$true)]
        [String]
        $Property,
        $Columns
    )

    BEGIN
    {
        $Width = $Host.UI.RawUI.BufferSize.Width
        $Data = @()
    }

    PROCESS
    {
        # Add all of the objects from the pipeline into an array
        $Data += $Object
    }

    END
    {
        # Determine scale of graph    
        Try
        {
            $Largest = $Data.$Property | Sort-Object | Select-Object -Last 1 
        }

        Catch
        {
            Write-Warning "Failed to find property $Property"
            Return
        }

        if ($Largest)
        {
            # Add the width of all requested columns to each object
            $Data = $Data | Select-Object -Property $Columns | %{
                $Lengths = @()
                $Len = 0
                $Item = $_
                $Columns | %{
                    if ($Item.$($_))
                    {
                        $Len += $Item.$($_).ToString().Length
                    }
                }
                Add-Member -InputObject $Item -MemberType NoteProperty -Name Length -Value $Len -PassThru
                $Lengths += $Len
            }

            # Determine the available chart space based on width of all requested columns
            $Sample = $Lengths | Sort -Property Length | Select-Object -Last 1
            [Int]$Longest = $Sample.Length + ($Columns.Count * 33)
            $Available = $Width-$Longest-4
            
            ForEach ($Obj in $Data)
            {
                # Set bar length to 0 if it is not a number greater than 0
                if ($Obj.$Property -eq '-' -OR $Obj.$Property -eq 0 -or -not $Obj.$Property)
                {
                    [Int]$Graph = 0
                }
                else
                {
                    $Graph = (($Obj.$Property) / $Largest) * $Available
                }

                # Based on bar size, use a different character to visualize the bar
                if ($Graph -ge 2)
                {
                    [String]$G = [char]9608
                }
                elseif ($Graph -gt 0 -AND $Graph -le 1)
                {
                    [String]$G = [char]9612
                    $Graph = 1
                }

                # Create the property that will contain the bar
                $Char = $G * $Graph
                $Obj | Select-Object -Property $Columns | Add-Member -MemberType NoteProperty -Name Graph -Value $Char -PassThru
    
            } # End ForEach

        } # End if ($Largest)

    } # End of END block

} # End Out-ConsoleGraph