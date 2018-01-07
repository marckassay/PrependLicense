$SummaryTable = @{}
function Add-GPLHeader {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $True)]
        [string]$ProgramName,

        [Parameter(Mandatory = $True)]
        [string]$ProgramDescription,

        [Parameter(Mandatory = $True)]
        [string]$Author,

        [switch]$WhatIf
    )

    $Header = New-Header -Type 'GPL' -Path $Path -ProgramName $ProgramName -ProgramDescription $ProgramDescription -Author $Author
    $ConfirmationMessage = New-ConfirmationMessage -Type 'GPL' -Header $Header -WhatIf:$WhatIf.IsPresent
    $Decision = Request-Confirmation -Message $ConfirmationMessage -WhatIf:$WhatIf.IsPresent

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

        [Parameter(Mandatory = $True)]
        [string]$ProgramName,

        [Parameter(Mandatory = $True)]
        [string]$Author,
        
        [switch]$WhatIf
    )

    $Header = New-Header -Type 'MIT' -Path $Path -ProgramName $ProgramName -Author $Author
    $ConfirmationHeader = New-ConfirmationMessage -Type 'MIT' -Header $Header -WhatIf:$WhatIf.IsPresent
    $Decision = Request-Confirmation -Message $ConfirmationHeader -WhatIf:$WhatIf.IsPresent

    if ($Decision -eq $True) {
        Start-PrependProcess -Path $Path -Header $Header -WhatIf:$WhatIf.IsPresent
    }
    else {
        Write-Output -InputObject 'Procedure has been cancelled, no files have been modified.'
    }
}

function Add-Header {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $True)]
        [string]$Header,

        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Include,

        [switch]$WhatIf
    )

    $ConfirmationMessage = New-ConfirmationMessage -Type '' -Header $Header -WhatIf:$WhatIf.IsPresent
    $Decision = Request-Confirmation -Message $ConfirmationMessage -WhatIf:$WhatIf.IsPresent

    if ($Decision -eq $True) {
        Start-PrependProcess -Path $Path -Header $Header -Include $Include -WhatIf:$WhatIf.IsPresent
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
    The MIT License (MIT)

    Copyright ${Year} ${Author}

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
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
        [ValidateSet("GPL", "MIT", "")]
        [AllowEmptyString()]
        [string]$Type,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Header,

        [switch]$WhatIf
    )

    # if it's not a custom header, don't PadRight
    if ($Type.Length -gt 0) {
        $PaddedType = $Type.PadRight(4)
    }
    else {
        $PaddedType = $Type
    }
    
    if ($WhatIf.IsPresent -eq $False) {
        $ConfirmationMessage = @"
The following ${PaddedType}license will be prepended to all recognized file types:
${Header}
"@
    }
    else {
        $ConfirmationMessage = @"
The following ${PaddedType}license *would* be prepended to all recognized file types:
${Header}
"@
    }

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

        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Include,

        [switch]$WhatIf
    )
    try {
        
        if ((Test-Path $Path) -eq $False) {
            if (Test-Path -PathType Container -IsValid) {
                throw [System.IO.DirectoryNotFoundException]::new()
            }
            elseif (Test-Path -PathType Leaf -IsValid) {
                throw [System.IO.FileNotFoundException]::new()
            }
            else {
                throw [System.IO.IOException]::new() 
            }
        }

        $IsContainer = Resolve-Path $Path | Test-Path -IsValid -PathType Container
        
        if ($IsContainer -eq $True) {
            Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {
                if ($_.PSIsContainer -eq $False) {
                    Add-PrependContent -Path $_.FullName -Value $Header -Include $Include -WhatIf:$WhatIf.IsPresent
                }
            }
        }
        else {
            Add-PrependContent -Path $Path -Value $Header -Include $Include -WhatIf:$WhatIf.IsPresent 
        }

        Format-SummaryTable -WhatIf:$WhatIf.IsPresent
        # clear table to be used again in session...
        $SummaryTable.Clear()
    }
    catch [System.IO.DirectoryNotFoundException] {
        Write-Error -Message ("The following directory cannot be found: $Path")
    }
    catch [System.IO.FileNotFoundException] {
        Write-Error -Message ("The following file cannot be found: $Path")
    }
    catch [System.IO.IOException] {
        Write-Error -Message ("The following is invalid: $Path")
    }
    catch {
        Write-Error -Message ("An error occurred when attempting to prepend the following target: $Path")
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

        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Include,

        [switch]$WhatIf
    )

    $FileContents = Get-Item $Path -OutVariable File | Get-Content -Raw
    # if Include is defined and it contains the current Extension...
    if ($Include -and $Include.Split(',').Contains('*' + $File.Extension) -eq $True) {
        $ValuePrefixedToFile = @"
${Value}
${FileContents}
"@
    }
    elseif (!$Include) {
        $Brackets = Get-FileTypeBrackets -FileExtension $File.Extension

        if ($Brackets) {
            $ValuePrefixedToFile = @"
$($Brackets.Opening.Trim())
${Value}
$($Brackets.Closing.Trim())
${FileContents}
"@
        }
    }
    
    if ($ValuePrefixedToFile) {
        if (!$WhatIf.IsPresent) {
            Set-File
        }
        else {
            Out-File -FilePath $Path -InputObject $ValuePrefixedToFile -WhatIf
        }
        
        Set-SummaryTable -FileExtension $File.Extension -Modified $True
    }
    else {

        Set-SummaryTable -FileExtension $File.Extension -Modified $False

        if ($Verbose.IsPresent) {
            Write-Verbose ("VERBOSE: Ignoring the operation 'Output to File' on unrecognized target: " + $_.FullName)
        }
        if ($WhatIf.IsPresent) {
            Write-Output -InputObject ("What if: Would ignore the operation 'Output to File' on unrecognized target: " + $_.FullName)
        }
    }
}

function Set-SummaryTable {
    Param
    (
        [Parameter(Mandatory = $True)]
        [string]$FileExtension,

        [Parameter(Mandatory = $True)]
        [bool]$Modified
    )
    # TODO: perhaps Group-Object can be used in here
    if ($SummaryTable.ContainsKey($FileExtension) -eq $True) {
        ($SummaryTable[$FileExtension].Count)++
    }
    else {
        $YesNo = if ($Modified -eq $True) {'Yes'} else {'No'}
        $NewEntry = [PSCustomObject]@{Count = 1; Modified = $YesNo}
        $SummaryTable.Add($FileExtension, $NewEntry)
    }
}

function Format-SummaryTable {
    [CmdletBinding()]
    Param
    (
        [switch]$WhatIf
    )
    
    if ($WhatIf.IsPresent) {
        Write-Output @"

Since the 'WhatIf' was switched, below is the what would of happened summary:
"@
    }
    Format-Table @{Label = "Found Files"; Expression = {($_.Name)}}, `
    @{Label = "Count"; Expression = {($_.Value.Count)}}, `
    @{Label = "Modified"; Expression = {($_.Value.Modified)}}`
        -AutoSize -InputObject $SummaryTable
}

# ref: http://stackoverflow.com/a/24649481
function Request-Confirmation {
    Param
    (
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$Message,

        [switch]$WhatIf
    )
    
    if ($WhatIf.IsPresent -eq $false) {
        $Question = 'Do you want to proceed?'
    }
    else {
        $Question = 'Do you want to simulate what will happen?'
    }

    $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes"))
    $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&No"))

    [bool]$Decision = !($Host.UI.PromptForChoice($Message, $Question, $Choices, 1))
    
    $Decision
}

function Get-FileTypeBrackets {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [string]$FileExtension
    )

    process {
    
        $KeyFound = $FileTypeTable.GetEnumerator() | Where-Object -Property Value  -Match $FileExtension | Select-Object -ExpandProperty Name

        if ($KeyFound) {
            $BracketsRaw = $BracketTable[$KeyFound]
            $Brackets = [PSCustomObject]@{
                Opening = $BracketsRaw.Trim().Split(',')[0]
                Closing = $BracketsRaw.Trim().Split(',')[1]
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

# $OutputEncoding
# $OFS = $Info.LineEnding
function Set-File {
    [CmdletBinding()]

    [byte]$CR = 0x0D # 13
    [byte]$LF = 0x0A # 10

    New-Object -TypeName System.IO.StreamReader -ArgumentList $Path -OutVariable StreamReader | Out-Null
    # TODO: add/check value with constraints: unknown, string, unicode, bigendianunicode, utf8, utf7, utf32, ascii, default, oem
    $Encoding = $StreamReader.CurrentEncoding.WebName.Replace('-', '')

    New-Object -TypeName System.IO.BinaryReader -ArgumentList $StreamReader.BaseStream -OutVariable BinaryReader | Out-Null
    
    if ($BinaryReader.BaseStream.CanRead -eq $true -and $BinaryReader.BaseStream.Length -gt 0) {
        $BinaryReader.BaseStream.Position = 0
        $BytesRead = $BinaryReader.ReadBytes($BinaryReader.BaseStream.Length)
        $IndexOfLF = $BytesRead.IndexOf($LF)

        if ($IndexOfLF) {
            # check previous char for 'CR', if so this file has 'CRLF' for EOL
            # and we shouldnt have to do anything.  but if its a lone LF, edit 
            # $ValuePrefixedToFile to have just LF and not CRLF which PowerShell seems to 
            # default to.  See - $OFS
            if ($BytesRead[$IndexOfLF - 1] -ne $CR) {
                $ValuePrefixedToFile = $ValuePrefixedToFile -replace "\r", ""
            }
        }
    }

    $StreamReader.Close()
    $BinaryReader.Close()
  
    Out-File -FilePath $Path -InputObject $ValuePrefixedToFile -Encoding $Encoding -NoNewline # -WhatIf:$WhatIf.IsPresent
}

# "imports" $FileTypeTable and $BracketTable
Invoke-Expression -Command (Get-Content -Raw -Path $PSScriptRoot'\PrependLicenseVariables.ps1')