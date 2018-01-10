# PrependLicense

PrependLicense is a PowerShell module that automates prepending license headers to code files.

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/marckassay/PrependLicense/blob/master/LICENSE) [![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/PrependLicense/)

## Features

* Predefined GPL, MIT license functions via `Add-GPLHeader` and `Add-MITHeader`
* Prepending custom header is available via `Add-Header` function which can also be used for unknown file types
* Simulate what will happen via `WhatIf` switch on any of the "Add" functions as listed below
* Sensitive to DTD tags (`<!DOCTYPE>`) in HTML files
* Attempts to preserve existing file encoding and to preserve end-of-line (EOL) markings

## Caveat

* In order to add license headers to files, this module needs to know the opening and closing comment brackets for each file type by extension.  This is predefined in the `PrependLicenseVariables.ps1` file.  Most likely you will need to modify this file for your needs or pass-in an inclusion string to `Add-Header` (read next paragraph).  When installed, you can find where this module resides on the filesystem executing:

```powershell
Get-Module PrependLicense | Select-Object {$_.Path}
```

   You can use the `Add-Header` to pass-in your own header with or without comment brackets included.  With the comment brackets included in the header, you can only target one type of file (I'm using the word "type" as a file having the same comment brackets as others).  See `Add-Header` function in the Usage section for more information.

* This module was developed for another repo of mine, which you can see the [commit](https://github.com/marckassay/AIT/commit/8505bfbf50137fc4ef238f311f818c4ab7a0354b) I made using PrependLicense.  As of this typing, PrependLicense module worked for my needs in an environment of:
  * Windows 10
  * PowerShell 5.1.16299.98
  * UTF-8, primarily EOL of 'LF'

* There seems to be a change of last EOL marking on files.  A ticket is opened for this [issue](https://github.com/marckassay/PrependLicense/issues/1).

## Instructions

* To install with PowerShellGet run the following command below.  Or download project to your PowerShell Module directory.
    ```powershell
    Install-Module PrependLicense
    ```

## Usage

* All 3 methods below have the option of running in simulation mode, via `WhatIf` switch.  I recommend to initially switch `WhatIf` to verify what will and will not be modified.

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

Below, `$MarcsLicense` is a header variable that is used with `Add-Header`.  The value passed to `Header` parameter will be applied to all predefined file types that are in the `PrependLicenseVariables.ps1` file, unless the `Include` parameter is used.

The `Include` parameter can be used to target files types that are not predefined.  If this is used, then the value for `Header` parameter must be in a form of a comment.  In otherwords, if you want to prepend file types unknown to this module, you must include the header in a form of a comment.

To see a session using `Add-Header` for known and unknown file types see the file in this repo: example/example-1.txt

Using `Add-Header` to apply a custom header with predefined file types that are listed in the `PrependLicenseVariables.ps1` file.

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