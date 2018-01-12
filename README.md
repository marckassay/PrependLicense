# PrependLicense

PrependLicense is a PowerShell module that automates prepending license headers to code files.

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/marckassay/PrependLicense/blob/master/LICENSE) [![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/PrependLicense/)

## Features

* Predefined GPL, MIT license functions via `Add-GPLHeader` and `Add-MITHeader`
* Prepending custom header is available via `Add-Header` function which can also be used for unknown file types
* Simulate what will happen via `WhatIf` switch on any of the "Add" functions as listed below
* Preserves end-of-line (EOL) markings and sensitive to DTD tags (`<!DOCTYPE>`) in HTML files
* Allows you to set your own comment brackets for file types

## Caveat

In order to add license headers to files, this module needs to know the opening and closing comment brackets for each file type by extension that you wish to modify. Most likely you will need to modify these tables using the `Set-FileTypeTable` and `Set-BracketTable` functions.  See documentation in the Usage section for these functions.

## Instructions

To install, run the following command in PowerShell.

```powershell
$ Install-Module PrependLicense
```

## Usage

All of the 3 Add functions below have the option of running in simulation mode, via `WhatIf` switch.  I recommend to initially switch `WhatIf` to verify what will and will not be modified.

### Add-GPLHeader

```powershell
$ Add-GPLHeader -Path .\src\ -ProgramName 'AiT' -ProgramDescription 'Another Interval Timer' -Author 'Marc Kassay'
```

Using the `WhatIf` switch.

```powershell
$ Add-GPLHeader -Path .\src\ -ProgramName 'AiT' -ProgramDescription 'Another Interval Timer' -Author 'Marc Kassay' -WhatIf
```

### Add-MITHeader

Notice this function doesn't take the `ProgramDescription` parameter as the `Add-GPLHeader` requires.

```powershell
$ Add-MITHeader -Path .\src\ -ProgramName 'AiT' -Author 'Marc Kassay'
```

### Add-Header

When using the generic `Add-Header` function, I recommend to use "here-string" as shown below.  For information on "here-string" visit this [about link](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-5.1) and goto the section titled "HERE-STRINGS".
Below, `$MarcsLicense` is a header variable that is used with `Add-Header`.  The value passed to `Header` parameter will be applied to all file types that are predefined, unless either of the following conditions are true:

* the `Include` parameter was used.  The `Include` parameter can be used to target files types that are not predefined.  If this is used, then the value for `Header` parameter must be in a form of a comment as it will be used "as-is".  To see a session using `Add-Header` for known and unknown file types see the example file here [example/example-1.txt](https://github.com/marckassay/PrependLicense/blob/master/example/example-1.txt)

* the `Set-FileTypeTable` function was used.  With this function you can essentially remove and add file types along their corresponding comment brackets with `Set-BracketTable` function.  For more information, see these functions below.


```powershell
$ $MarcsLicense = @"
   AS OF: JAN2018:
   DO NOT: 'SELL', 'TRADE' or 'EXCHANGE' CODE BELOW!!!
"@
$ Add-Header -Path .\src\ -Header $MarcsLicense
```

Using `Add-Header` to apply a custom header in a form of a comment to unknown file types that are set in the `Include` parameter.

```powershell
$ $MarcsLicense = @"
   %% AS OF: JAN2018:
   %% DO NOT: 'SELL', 'TRADE' or 'EXCHANGE' CODE BELOW!!!
"@
$ Add-Header -Path .\src\ -Header $MarcsLicense -Include '*.m52, *.m53'
```

### Get-FileTypeTable

Outputs the `$FileTypeTable`.  The following is the default value for this variable:

```powershell
$ Get-FileTypeTable
Name                           Value
----                           -----
5                              *.rb
4                              *.scss, *.css
3                              *.html
2                              *.psm1, *.psd1, *.ps1
1                              *.ts, *.js, *.cp, *.java, *.class
```

### Set-FileTypeTable

You may overwrite the default `$FileTypeTable` by piping a hashtable to this function.

```powershell
$ $ProjectFileTypes = @{
 1 = "*.aml, *.bml"
 2 = "*.as, *.bs"
}
$ $ProjectFileTypes | Set-FileTypeTable
$ Get-FileTypeTable
Name                           Value
----                           -----
2                              *.as, *.bs
1                              *.aml, *.bml
```

In an addition to piping, you can add key value pairs as passing them in as arguments.

```powershell
$ Set-FileTypeTable 3 "*.txt"
$ Get-FileTypeTable
Name                           Value
----                           -----
3                              *.txt
2                              *.as, *.bs
1                              *.aml, *.bml
```

### Get-BracketTable

Outputs the `$BracketTable`.  The following is the default value for this variable:

```powershell
$ Get-BracketTable
Name                           Value
----                           -----
5                              =begin,    =end
4                              /*,        */
3                              <!--,      -->
2                              <#,        #>
1                              /**,       */
```

### Set-BracketTable

This has the same behavior as `Set-FileTypeTable` except the constraint on the value parameter.  By analysing the values from a `Get-BracketTable` call, you may have noticed that opening and closing bracket must be separated by a comma which is required.  Also value must be in a string and you cannot modify any existing entries.  If needed, you can pipe into this function with another hashtable to overwrite the default `$BracketTable`.