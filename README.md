# PrependLicense
PrependLicense is a PowerShell module that automates prepending license headers to code file(s).  

### Features
* GPL and MIT license templates are predefined
* Custom template is available via `Add-Header` function and for unknown types
* Simulate what will happen via `WhatIf` switch on any of the "Add" functions as listed below

### Cavet
* In order to add license headers to files, this module needs to know the opening and closing comment brackets for each file type by extension.  This is predefined in the `PrependLicenseVariables.ps1` file.  Most likely you will need to modify this file for your needs or pass-in an inclusion string to `Add-Header` (read next paragraph).  A nice to have PR would be to modify these variables that are in this file via CLI.  And/or a PR with additional entries.  
    
    You can use the `Add-Header` to pass-in your own header with or without comment brackets included.  With the comment brackets included in the header, you can only target one type of file.  "Type" is being defined as having the same comment brackets.  See `Add-Header` function in the Usage section for more information.

## Instructions
* To install with PowerShellGet run the following command below.  Or download project to your PowerShell Module directory.
	```powershell
	Install-Module PrependLicense
	```

## Usage
* All 3 methods below have the option of running in simulation mode, via `WhatIf` switch.  I recommend to switch `WhatIf` to verify what will and will not be modified.

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
    
    The `Include` parameter can be used to target files types that are not predefined.  If this is used, then the value of `Header` parameter must be in a form of a comment.  In otherwords, if you want to prepend file types unknown to this module, you must include the header in a comment form.

    To see a session using `Add-Header` to apply a header for known and unknown types see the file in this repo: example/example-1.txt

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