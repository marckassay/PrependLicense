<# 
Add-GPLHeader -Path E:\Temp\Testff\src\ -ProgramName 'AiT' -ProgramDescription 'Another Interval Timer' -Author 'Marc Kassay'
Add-MITHeader -Path E:\Temp\Testff\src\ -ProgramName 'AiT' -Author 'Marc Kassay'
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
    
    $Header = New-Header -Type 'GPL' -Path $Path -ProgramName $ProgramName -ProgramDescription $ProgramDescription -Author $Author
    $ConfirmationHeader = New-ConfirmationMessage -Type 'GPL' -Header $Header
    $Decision = Get-Confirmation -Message $ConfirmationHeader

    if ($Decision -eq $True) {
        Start-PrependProcess -Path $Path -Header $Header -WhatIf:$WhatIf.IsPresent
    }
    else {
        Write-Output -InputObject 'Procedure has been cancelled, no files have been modified.'
    }
}

function Add-MITHeader {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $False)]
        [string]$ProgramName,

        [Parameter(Mandatory = $False)]
        [string]$Author,
        
        [switch]$WhatIf
    )
    
    $Header = New-Header -Type 'MIT' -Path $Path -ProgramName $ProgramName -ProgramDescription $ProgramDescription -Author $Author
    $ConfirmationHeader = New-ConfirmationMessage -Type 'MIT' -Header $Header
    $Decision = Get-Confirmation -Message $ConfirmationHeader

    if ($Decision -eq $True) {
        Start-PrependProcess -Path $Path -Header $Header -WhatIf:$WhatIf.IsPresent
    }
    else {
        Write-Output -InputObject 'Procedure has been cancelled, no files have been modified.'
    }
}

function New-Header {

    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateSet("GPL", "MIT")]
        [string]$Type,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $False)]
        [string]$ProgramName,

        [Parameter(Mandatory = $False)]
        [string]$ProgramDescription,

        [Parameter(Mandatory = $False)]
        [string]$Author
    )

    $Year = (Get-Date).Year

    if ($Type -eq 'GPL') {
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
    }
    elseif ($Type -eq 'MIT') {
        $Header = @"
Copyright ${Year} ${Author}

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    
"@
    }

    $Header
}

function New-ConfirmationMessage {
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateSet("GPL", "MIT")]
        [string]$Type,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Header,

        [switch]$WhatIf
    )
    # TODO: implement WhatIf into message
    $ConfirmationMessage = @"
The following ${Type} license will be prepended to all recognized file types:

${Header}

"@

    $ConfirmationMessage
}

function Start-PrependProcess {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $True)]
        [string]$Header,

        [switch]$WhatIf
    )
    try {
        # TODO: hmmm...this Test-Path cmd says paths are valid even if they dont exist...
        #  if ((Test-Path $Path -IsValid)) {
        #     throw New-Object -TypeName [System.IO.IOException]
        # }
        $IsContainer = Resolve-Path $Path | Test-Path -IsValid -PathType Container

        if ($IsContainer -eq $True) {
            Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {
                if ($_.PSIsContainer -eq $False) {
                    Add-PrependContent -Path $_.FullName -Value $Header -WhatIf:$WhatIf.IsPresent 
                }
            }
        }
        else {
            Add-PrependContent -Path $Path -Value $Header -WhatIf:$WhatIf.IsPresent 
        }
    }
    catch {
        Write-Error -Message 'An error occurred when attempting to prepend the following target: '+$Path
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

        Out-File -FilePath $Path -InputObject $ValuePrefixedToFile -WhatIf:$WhatIf.IsPresent
    }
    else {
        if ($Verbose.IsPresent) {
            Write-Verbose ("VERBOSE: Ignoring the operation 'Output to File' on unrecognized target: " + $_.FullName)
        }
        if ($WhatIf.IsPresent) {
            Write-Output -InputObject ("What if: Would ignore the operation 'Output to File' on unrecognized target: " + $_.FullName)
        }
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

        if ($KeyFound) {
            $BracketsRaw = $BracketTable[$KeyFound]
            $Brackets = [PSCustomObject]@{
                Opening = $BracketsRaw.Split(',')[0]
                Closing = $BracketsRaw.Split(',')[1]
            }
        }
        else {
            $Brackets = $null
        }
    }
    end {
        $Brackets
    }
}
