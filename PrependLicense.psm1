<# 
Add-GPLHeader -Path E:\Temp\Testff\src\ -ProgramName 'AiT' -ProgramDescription 'Another Interval Timer' -Author 'Marc Kassay'
#>
function Add-GPLHeader {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $False)]
        [string]$ProgramName,

        [Parameter(Mandatory = $False)]
        [string]$ProgramDescription,

        [Parameter(Mandatory = $False)]
        [string]$Author,
        
        [switch]$WhatIf
    )
    
    $Year = (Get-Date).Year

    $Header = @"
    ${ProgramName} - ${ProgramDescription}
    Copyright (C) ${Year} ${Author}

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

"@

    $Decision = Get-Confirmation -Message @"
The following GPL license will be prepended to all file types known by this module:

    ${Header}

"@
    if ($Decision -eq $True) {
        try {
            # TODO: hmmm...this Test-Path cmd says paths are valid even if they dont exist...
            #  if ((Test-Path $Path -IsValid)) {
            #     throw New-Object -TypeName [System.IO.IOException]
            # }

            $IsContainer = Resolve-Path $Path | Test-Path -IsValid -PathType Container

            if ($IsContainer -eq $True) {
                Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {
                    if ($_.PSIsContainer -eq $False) {
                        Add-PrependContent -Path $_.FullName -Value $Header -WhatIf:$WhatIf.IsPresent -Verbose:$Verbose.IsPresent
                    }
                }
            }
            else {
                Add-PrependContent -Path $Path -Value $Header -WhatIf:$WhatIf.IsPresent -Verbose:$Verbose.IsPresent
            }
        }
        catch [System.IO.IOException] {
            Write-Error -Message 'The following path given, is invalid: '+$Path
        } 
        catch {
            Write-Error -Message 'An exception occurred when prepending!  Halting operation.'
        }
    }
    else {
        Write-Out -InputObject 'Procedure has been cancelled, no files have been modified.'
    }
}

function Add-PrependContent {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $True)]
        [string]$Value,

        [switch]$WhatIf
    )
    
    $Brackets = Get-Item $Path | Select-Object { $_.Extension } -ExpandProperty Extension | Get-FileTypeBrackets

    if ($Brackets) {
        $FileContents = Get-Content $Path | Out-String

        $ValuePrefixedToFile = @"
$($Brackets.Opening)
${Value}
$($Brackets.Closing)
${FileContents}
"@

        Out-File -FilePath $Path -InputObject $ValuePrefixedToFile -WhatIf:$WhatIf.IsPresent -Verbose:$Verbose.IsPresent

        if ($WhatIf.IsPresent -eq $False) {
            Write-Output -InputObject ("Prefixed to: " + $_.FullName)
        }

        # $Results
    }
    else {
        Write-Verbose 'Ignoring unkown file type: '+$Path
    }
}
function Add-MITHeader {

}

# ref: http://stackoverflow.com/a/24649481
function Get-Confirmation {
    Param
    (
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$Message
    )
    
    $Question = 'Do you want to proceed?'

    $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes"))
    $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&No"))

    [bool]$Decision = !($Host.UI.PromptForChoice($Message, $Question, $Choices, 1))
    
    $Decision
}
#Export-ModuleMember -Function Get-Confirmation

function Get-FileTypeBrackets {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [AllowNull()]
        [string]$FileExtension
    )

    process {
        $FileTypeTable = @{ 
            1 = '*.ts, *.js, *.cp'
            2 = '*.psm1, *.psd1, *.ps1'
            3 = '*.html'
            4 = '*.scss, *.css'
        }
        $BracketTable = @{ 
            1 = '/**, */'
            2 = '<#, #>'
            3 = '<!--,-->'
            4 = '/*,*/'
        }

        $KeyFound = $FileTypeTable.GetEnumerator() | Where-Object -Property Value  -Match $FileExtension | Select-Object -ExpandProperty Name

        $BracketsRaw = $BracketTable[$KeyFound]
        if ($BracketsRaw) {
            $Brackets = [PSCustomObject]@{
                Opening = $BracketsRaw.Split(',')[0]
                Closing = $BracketsRaw.Split(',')[1]
            }
        }
        else {
        }
    }
    end {
        $Brackets
    }
}
