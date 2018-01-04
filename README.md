# PrependLicense
PrependLicense is a PowerShell module that automates prepending license headers to file(s).  

### Features
* GPL and MIT license templates are predefined
* Custom template is available via `Add-Header` function
* Simulate what will happen via `WhatIf` switch on any of the "Add" functions as listed below

### Cavet
* In order to add license headers to the file, this module needs to know the opening and closing comment brackets.  This is predefined in the `PrependLicenseVariables.ps1` file.  Most likely you will need to modify this file for your needs.  A nice to have PR would be to modify these variables which are in this file.  Or at least a PR with additional entries.  
    
    If you need this done sooner then later, use the `Add-Header` and pass-in your own header and specify each file type per header.  See this function in the Usage section.

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
    When using the generic `Add-Header` function, I recommend to use "here-string" as shown below.  For information on "here-string" visit this [about link](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-5.1) and goto the section titled "HERE-STRINGS"

    The `Include` parameter is required since this the required `Header` parameter value can only have one style of commenting.  This parameter takes an array of strings.
    ```powershell
    $MarcsLicense = @"
    # AS OF: JAN2018:
    # DO NOT: 'SELL', 'TRADE' or 'EXCHANGE' CODE BELOW!!!
    "@
    $ Add-Header -Path .\src\ -Header $MarcsLicense -Include '*.ts'
    ```