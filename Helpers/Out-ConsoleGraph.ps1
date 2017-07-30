function Out-ConsoleGraph {

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,
                   ValueFromPipeline=$true)]
        [Object]
        $InputObject,
        [Parameter(Mandatory=$true)]
        [String]
        $Property,
        $Columns
        )

    BEGIN {
        $Width = $Host.UI.RawUI.BufferSize.Width
        $Data = @()
    }

    PROCESS {
        $Data += $InputObject
    }

    END {
        
        Try {
            $Largest = $Data | Sort-Object $Property | Select -ExpandProperty $Property -Last 1 -ErrorAction Stop
        }

        Catch {
            Write-Warning "Failed to find property $Property"
            Return
        }

        if ($Largest) {
            $Data = $Data | Select $Columns | %{
                $Lengths = @()
                $Len = 0
                $Item = $_
                $Columns | %{
                    $Prop = $_
                    $Len += $Item.$($Prop).ToString().Length
                    }
                Add-Member -InputObject $Item -MemberType NoteProperty -Name Length -Value $Len -PassThru
                $Lengths += $Len
            }

        $Sample = $Lengths | Sort Length | Select-Object -Last 1
        [Int]$Longest = $Sample.Length + ($Columns.Count * 33)
        $Available = ($Width-$Longest-4)/100

        ForEach ($Obj in $Data) {
            
            if ($Obj.$Property -eq '-' -OR $Obj.$Property -eq 0) {
                [Int]$Graph = 0
                }
            else {
                $Graph = (($Obj.$Property) / $Largest) * 100 * $Available
                }

            if ($Graph -ge 2) {
                [String]$G = [char]9608
                }
            elseif ($Graph -gt 0 -AND $graph -le 1) {
                [String]$G = [char]9612
                $Graph = 1
            }

            $Char = $G * $Graph
            $Obj | Select $Columns | Add-Member -MemberType NoteProperty -Name Graph -Value $Char -PassThru
    
            } # End ForEach

        } # End if ($Largest)

    } # End of END block

} # End Out-ConsoleGraph