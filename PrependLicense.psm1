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
                    Open-File -FilePath $_.FullName | Write-File -Header $Header -Include $Include -WhatIf:$WhatIf.IsPresent | Close-File
                }
            }
        }
        else {
            # Add-PrependContent -Path $Path -Value $Header -Include $Include -WhatIf:$WhatIf.IsPresent 
            Open-File | Write-File | Close-File
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

function Set-SummaryTable {
    Param
    (
        [Parameter(Mandatory = $True)]
        [string]$FileItem,

        [Parameter(Mandatory = $True)]
        [bool]$Modified
    )
    # TODO: perhaps Group-Object can be used in here
    if ($SummaryTable.ContainsKey($FileItem) -eq $True) {
        ($SummaryTable[$FileItem].Count)++
    }
    else {
        $YesNo = if ($Modified -eq $True) {'Yes'} else {'No'}
        $NewEntry = [PSCustomObject]@{Count = 1; Modified = $YesNo}
        $SummaryTable.Add($FileItem, $NewEntry)
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
    
        $KeyFound = $FileTypeTable.GetEnumerator() | Where-Object -Property Value -Match $FileExtension | Select-Object -ExpandProperty Name

        if ($KeyFound) {
            $BracketsRaw = $BracketTable[$KeyFound]
            $Brackets = [PSCustomObject]@{
                Opening = $BracketsRaw.Split(',')[0].Trim()
                Closing = $BracketsRaw.Split(',')[1].Trim()
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

<#
.SYNOPSIS
Set variables for Write-File which is next in the pipeline

.DESCRIPTION
Opens StreamReader and BinaryReader to set variables for Write-File which is next in the pipeline.  This will
close StreamReader and BinaryReader after all variables are set

.PARAMETER Path
Path to the file.

.EXAMPLE
An example

.NOTES
System.IO.BinaryReader is being used here to retrieve the line endings as I believe this is the only way it can be done.
#>
function Open-File {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [string]$FilePath
    )

    $FileItem = Get-Item -Path $FilePath
    New-Object -TypeName System.IO.StreamReader -ArgumentList $FileItem.FullName -OutVariable StreamReader | Out-Null
    # See NOTES for the function on why this is being used.
    New-Object -TypeName System.IO.BinaryReader -ArgumentList $StreamReader.BaseStream -OutVariable BinaryReader | Out-Null

    $FileAsString = $StreamReader.ReadToEnd();
    
    [byte]$CR = 0x0D # 13  or  \r\n  or  `r`n
    [byte]$LF = 0x0A # 10  or  \n    or  `n
    if ($BinaryReader.BaseStream.CanRead -eq $true -and $BinaryReader.BaseStream.Length -gt 0) {
        $BinaryReader.BaseStream.Position = 0
        $FileAsBytes = $BinaryReader.ReadBytes($BinaryReader.BaseStream.Length)
        $IndexOfLF = $FileAsBytes.IndexOf($LF)
        $RemoveLastLine = ($FileAsBytes.Get($FileAsBytes.Length - 1) -eq $LF)

        $IndexOfLF = $FileAsBytes.IndexOf($LF)
        if ($FileAsBytes[$IndexOfLF - 1] -ne $CR) {
            $EOL = 'LF'
        }
        else {
            $EOL = 'CRLF'
        }
    }
    
    

    # this if statement is to determine the file's line endings and change the text that 
    # will be written to the file, if needed.

    $BinaryReader.Dispose()
    $StreamReader.Dispose()

    $Data = [PsObject]@{
        RemoveLastLine = $RemoveLastLine
        FileItem       = $FileItem
        EOL            = $EOL
        FileAsString   = $FileAsString
        Encoding       = ''
    }
    $Data 
}

<#
.SYNOPSIS
From the variables set from Open-File, Write-File will make logically decisions on what and how the contents 
are arranged and written to file.

.DESCRIPTION
Long description

.PARAMETER Header
User defined header

.PARAMETER Include
Inclusion filter for files

.PARAMETER WhatIf
If true running in simulation mode

.EXAMPLE
An example

.NOTES
General notes
#>
function Write-File {
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline = $True)]
        [PsObject]$Data,

        [Parameter(Mandatory = $True)]
        [string]$Header,

        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Include,

        [Parameter(Mandatory = $True)]
        [switch]$WhatIf
    )

    New-Object -TypeName System.IO.StreamWriter -ArgumentList $Data.FileItem.FullName -OutVariable StreamWriter | Out-Null

    if ($Data.FileItem.Extension -eq ".html") {
        $HTMLDirective = $Data.FileAsString | Select-String -Pattern '.*DOCTYPE.*'
        if ($HTMLDirective.Matches.Success) {
            $Data.FileAsString = $Data.FileAsString.Replace($HTMLDirective.Matches.Value, "").Trim()
        }
    }

    # if Include is defined and it contains the current Extension...
    if ($Include -and $Include.Split(',').Contains('*' + $Data.FileItem.Extension) -eq $True) {
        $HeaderPrependedToFileString = @"
${Header}
$($Data.FileAsString)
"@
    }
    elseif (!$Include) {
        $Brackets = Get-FileTypeBrackets -FileExtension $Data.FileItem.Extension

        if ($Brackets) {
            $HeaderPrependedToFileString = @"
$($Brackets.Opening)
${Header}
$($Brackets.Closing)
$($Data.FileAsString)
"@
        }
    }

    if ($HeaderPrependedToFileString) {
        #if ($Data.RemoveLastLine) {
        #   $HeaderPrependedToFileString = $HeaderPrependedToFileString.TrimEnd("`r`n")
        #}

        # add the DTD tag at the very top of file, if there was one...
        if ($HTMLDirective.Matches.Success) {
            $HeaderPrependedToFileString = $HeaderPrependedToFileString.Insert(0, $HTMLDirective.Matches.Value + "`r`n")
        }
    
        # check previous char for 'CR', if so this file has 'CRLF' for EOL
        # and we shouldnt have to do anything since PowerShell defaults to 
        # the same EOL markings.  but if this file has lone LF endings, edit
        # $HeaderPrependedToFileString to have just LF endings too. Although the 
        # following global PS variables may be benefical here, I'm considering
        # individual files EOL markings.
        # $OutputEncoding
        # $OFS = $Info.LineEnding
        if ($Data.EOL -eq 'LF') {
            $HeaderPrependedToFileString = $HeaderPrependedToFileString -replace "`r", ""
        }

        if (!$WhatIf.IsPresent) {
            $StreamWriter.WriteLine($HeaderPrependedToFileString)
        } 

        Set-SummaryTable -FileItem $Data.FileItem.FullName -Modified $True
    }
    else {
        Set-SummaryTable -FileItem $Data.FileItem.FullName -Modified $False
    }

    try {
        $StreamWriter.Dispose()
    }
    catch {
        Write-Host "!!!BinaryWriter or StreamWriter error!!!"
    }
    
    $Data.Encoding = $StreamWriter.Encoding
    $Data
}

function Close-File {
    [CmdletBinding()]
    Param 
    (
        [Parameter(ValueFromPipeline = $True)]
        [PsObject]$Data
    )

    if ($Data.EOL) {
        Write-Output -InputObject ("What if: For file " + $Data.FileItem.FullName + ", 
will be encoded as '" + $Data.Encoding.WebName + "' with end-of-line markings of '" + $Data.EOL + "'")
    }
    else {
        Write-Output -InputObject ("What if: For file " + $Data.FileItem.FullName + ", 
will be encoded as '" + $Data.Encoding.WebName)
    }

    if ($Verbose.IsPresent) {
        Write-Verbose ("VERBOSE: Ignoring unrecognized target: " + $Data.FileItem.FullName)
    }
    if ($WhatIf.IsPresent) {
        Write-Output -InputObject ("What if: Would ignore modifying on unrecognized target: " + $Data.FileItem.FullName)
    }
}

# "imports" $FileTypeTable and $BracketTable
Invoke-Expression -Command (Get-Content -Raw -Path $PSScriptRoot'\PrependLicenseVariables.ps1')