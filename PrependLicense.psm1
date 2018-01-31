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
                    Get-FileObject -FilePath $_.FullName -Header $Header -Include $Include -WhatIf:$WhatIf.IsPresent | `
                        Write-File  | Write-Summary
                }
            }
        }
        else {
            Get-FileObject -FilePath $_.FullName -Header $Header -Include $Include -WhatIf:$WhatIf.IsPresent | Write-File | Write-Summary
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

function Request-Confirmation {
    Param
    (
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$Message,

        [switch]$WhatIf
    )
    
    if ($WhatIf.IsPresent -eq $false) {
        $Question = 'Do you want to proceed in modifying file(s)?'
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
    
    $Brackets
}

<#
.SYNOPSIS
Set variable in an object for Write-File which is next function in the pipeline

.DESCRIPTION
Opens StreamReader to set variables for Write-File which is next in the pipeline.  This will
close StreamReader after all variables are set.
#>
function Get-FileObject {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [string]$FilePath,

        [Parameter(Mandatory = $True)]
        [string]$Header,

        [Parameter(Mandatory = $True)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Include,
        
        [switch]$WhatIf
    )

    $Data = [PsObject]@{
        Header               = $Header
        FileItem             = $null
        FileAsString         = ''
        EOL                  = ''
        Encoding             = $null
        EndsWithEmptyNewLine = $false
        Brackets             = ''
        ToInclude            = $false
        WhatIf               = $WhatIf.IsPresent
    }
  
    $Data.FileItem = Get-Item -Path $FilePath
    if (!$Include) {
        $Data.Brackets = Get-FileTypeBrackets -FileExtension $Data.FileItem.Extension
    }
    elseif ($Include.Split(',').Where( {$_ -like ('*' + $Data.FileItem.Extension)})) {
        $Data.ToInclude = $True
    }

    if ($Data.Brackets -or $Data.ToInclude) {
        New-Object -TypeName System.IO.StreamReader -ArgumentList $Data.FileItem.FullName -OutVariable StreamReader | Out-Null

        $Data.FileAsString = $StreamReader.ReadToEnd();

        [byte]$CR = 0x0D # 13  or  \r\n  or  `r`n
        [byte]$LF = 0x0A # 10  or  \n    or  `n
        $FileAsBytes = [System.Text.Encoding]::ASCII.GetBytes($Data.FileAsString)
        $FileAsBytesLength = $FileAsBytes.Length
        $IndexOfLF = $FileAsBytes.IndexOf($LF)
        if (($IndexOfLF -ne -1) -and ($FileAsBytes[$IndexOfLF - 1] -ne $CR)) {
            $Data.EOL = 'LF'
            if ($FileAsBytesLength) {
                $Data.EndsWithEmptyNewLine = ($FileAsBytes.Get($FileAsBytesLength - 1) -eq $LF) -and `
                ($FileAsBytes.Get($FileAsBytesLength - 2) -eq $LF)
            }
        }
        else {
            $Data.EOL = 'CRLF'
            if ($FileAsBytesLength) {
                $Data.EndsWithEmptyNewLine = ($FileAsBytes.Get($FileAsBytesLength - 1) -eq $LF) -and `
                ($FileAsBytes.Get($FileAsBytesLength - 3) -eq $LF)
            }
        }
        
        $StreamReader.Dispose()
    }

    $Data
}

<#
.SYNOPSIS
From the variables set from Get-FileObject, Write-File will make logical decisions on what and how the contents 
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
        [PsObject]$Data
        <#
        $Data = [PsObject]@{
        Header         = $Header
        FileItem       = $null
        FileAsString   = ''
        EOL            = ''
        Encoding       = $null
        EndsWithEmptyNewLine = $false
        Brackets       = ''
        ToInclude      = $false
        WhatIf         = $WhatIf.IsPresent }
        #>
    )
    
    if ($Data.Brackets -or $Data.ToInclude) {
        # If running in destructive mode (not in WhatIf) pass just the FullName to StreamWriter.
        # If running in destructive mode then it MUST have $True passed-in as second parameter 
        # which signifies to append.  Otherwise it will delete all contents of file.
        if (!$Data.WhatIf) {
            $StreamWriterArguments = $Data.FileItem.FullName
        }
        else {
            $StreamWriterArguments = @($Data.FileItem.FullName, $True)
        }
        New-Object -TypeName System.IO.StreamWriter -ArgumentList $StreamWriterArguments -OutVariable StreamWriter | Out-Null

        $Data.Encoding = $StreamWriter.Encoding

        # if this is a HTML file, remove and capture DTD tag.  this will be attached later in this function
        if ($Data.FileItem.Extension -eq ".html") {
            $DTDTagMatch = $Data.FileAsString | Select-String -Pattern '.*DOCTYPE.*'
            if ($DTDTagMatch.Matches.Success) {
                $Data.FileAsString = $Data.FileAsString.Replace($DTDTagMatch.Matches.Value, "").TrimStart()
            }
        }

        # if ToInclude is true just prepended header to file contents without brackets...
        if ($Data.ToInclude) {
            $HeaderPrependedToFileString = @"
${Header}
$($Data.FileAsString)
"@
        }
        else {
            $HeaderPrependedToFileString = @"
$($Data.Brackets.Opening)
${Header}
$($Data.Brackets.Closing)
$($Data.FileAsString)
"@
        }

        # add the DTD tag at the very top of file, if there was one...
        if ($DTDTagMatch.Matches.Success) {
            $HeaderPrependedToFileString = $HeaderPrependedToFileString.Insert(0, $DTDTagMatch.Matches.Value + "`r`n")
        }
    
        # if $Data.EOL equals 'CRLF' we shouldnt have to do anything since 
        # PowerShell defaults to the same EOL markings (at least on Windows).
        # but if this file has lone LF endings, edit $HeaderPrependedToFileString
        # to have just LF endings too. 
        #
        # Although the following may be benefical here in some environments:
        #  $OutputEncoding
        #  $OFS = $Info.LineEnding
        #  $StreamWriter.NewLine = $True (although, this is a get/set prop PowerShell
        #       cant set it)
        #  $TextWriter.CoreNewLine (StreamWriter inherits from this class)
        if ($Data.EOL -eq 'LF') {
            $HeaderPrependedToFileString = $HeaderPrependedToFileString -replace "`r", ""
            if ($Data.EndsWithEmptyNewLine) {
                $HeaderPrependedToFileString + "`n"
            }
        }
        elseif ($Data.EndsWithEmptyNewLine) {
            $HeaderPrependedToFileString + "`r`n"
        }

        try {
            if (!$Data.WhatIf) {
                $StreamWriter.Write($HeaderPrependedToFileString)
            }
            
            $StreamWriter.Flush()
            $StreamWriter.Close()
        }
        catch {
            Write-Error ("PrependLicense failed to call Dispose() successfully with: " + $Data.FileItem.FullName)
        }
    }

    $Data
}

function Write-Summary {
    [CmdletBinding()]
    Param 
    (
        [Parameter(ValueFromPipeline = $True)]
        [PsObject]$Data
        <#
        $Data = [PsObject]@{
        Header         = $Header
        FileItem       = $null
        FileAsString   = ''
        EOL            = ''
        Encoding       = $null
        RemoveLastLine = $false
        Brackets       = ''
        ToInclude      = $false 
        WhatIf         = $WhatIf.IsPresent }
        #>
    )

    if ($Data.Brackets -or $Data.ToInclude) {
        Set-SummaryTable -FileExtension $Data.FileItem.Extension -Modified $True
    }
    else {
        Set-SummaryTable -FileExtension $Data.FileItem.Extension -Modified $False
    }

    if ($Data.WhatIf) {
        if ($Data.EOL) {
            Write-Output -InputObject ("What if: For file " + $Data.FileItem.FullName + ", 
will be encoded as '" + $Data.Encoding.WebName + "' with end-of-line markings of '" + $Data.EOL + "'")
        }
        else {
            Write-Output -InputObject ("What if: For file " + $Data.FileItem.FullName + ", 
will be encoded as '" + $Data.Encoding.WebName)
        }
    }

    if (!$Data.FileAsString) {
        if ($Data.WhatIf) {
            Write-Output -InputObject ("What if: Would ignore modifying on unrecognized target: " + $Data.FileItem.FullName)
        }
        elseif ($Verbose.IsPresent) {
            Write-Verbose ("VERBOSE: Ignoring unrecognized target: " + $Data.FileItem.FullName)
        }
    }
}

# "imports" $FileTypeTable and $BracketTable
Invoke-Expression -Command (Get-Content -Raw -Path $PSScriptRoot'\PrependLicenseVariables.ps1')