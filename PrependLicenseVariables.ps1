

$FileTypeTable = @{ 
    1 = '*.ts, *.js, *.cp, *.java, *.class'
    2 = '*.psm1, *.psd1, *.ps1'
    3 = '*.html'
    4 = '*.scss, *.css'
    5 = '*.rb'
}
$BracketTable = @{ 
    1 = '/**,       */'
    2 = '<#,        #>'
    3 = '<!--,      -->'
    4 = '/*,        */'
    5 = '=begin,    =end'
}


function Get-FileTypeTable {
    [CmdletBinding()]
    [OutputType("System.Collections.Hashtable")]
    Param ()
    $FileTypeTable
}

function Get-BracketTable {
    [CmdletBinding()]
    [OutputType("System.Collections.Hashtable")]
    Param ()
    $BracketTable
}

function Set-FileTypeTable {
    [CmdletBinding(
        DefaultParameterSetName = 'KeyValue'
    )]
    [OutputType([void])]
    Param 
    (
        [Parameter(
            ParameterSetName = "InputObject",
            ValueFromPipeline = $True
        )]
        [System.Collections.Hashtable]$InputObject,

        [Parameter(
            ParameterSetName = "KeyValue"
        )]
        [Parameter(
            Position = 0
        )]
        [int]$Key,

        [Parameter(
            ParameterSetName = "KeyValue"
        )]
        [Parameter(
            Position = 1
        )]
        [ValidatePattern("[\*].[a-zA-Z0-9]")]
        [string]$Value
    )
    
    if ($InputObject) {
        $FileTypeTable.Clear()
        $InputObject.Keys | ForEach-Object {
            $FileTypeTable.Add($_, $InputObject[$_])
        }
    }
    else {
        $ExistingEntryValues = $FileTypeTable | Select-Object -ExpandProperty Values | ForEach-Object {$_.Split(',').Trim()}
        if ($Value.Contains(',')) {
            $ProposedEntryValues = $Value.Split(',').Trim()
        }
        else { 
            $ProposedEntryValues = $Value
        }
        $ProposedEntryValues | ForEach-Object {
            if ($ExistingEntryValues.Contains($_)) {
                Write-Host ("An existing entry value already exist of: " + $_)
            }
        }
        
        if ($FileTypeTable.ContainsKey($Key)) {
            $ExistingEntryValues = $FileTypeTable[$Key]
            $FileTypeTable[$Key] = $ExistingEntryValues + "," + $Value
        }
        else {
            $FileTypeTable.Add($Key, $Value)
        }
    }
}

function Set-BracketTable {
    [CmdletBinding(
        DefaultParameterSetName = 'KeyValue'
    )]
    [OutputType([void])]
    Param 
    (
        [Parameter(
            ParameterSetName = "InputObject",
            ValueFromPipeline = $True
        )]
        [System.Collections.Hashtable]$InputObject,

        [Parameter(
            ParameterSetName = "KeyValue"
        )]
        [Parameter(
            Position = 0
        )]
        [int]$Key,

        [Parameter(
            ParameterSetName = "KeyValue"
        )]
        [Parameter(
            Position = 1
        )]
        [ValidatePattern("(.+),(.+)")]
        [string]$Value
    )

    if ($InputObject) {
        $BracketTable.Clear()
        $InputObject.Keys | ForEach-Object {
            $BracketTable.Add($_, $InputObject[$_])
        }
    }
    else {
        $ExistingEntryValues = $BracketTable | Select-Object -ExpandProperty Values | ForEach-Object {$_.Split(',').Trim()}
        if ($ExistingEntryValues.Contains($Value[0]) -or $ExistingEntryValues.Contains($Value[1])) {
            Write-Host ("An existing entry value already exists that matches: " + $Value)
        }
    
        if ($BracketTable.ContainsKey($Key)) {
            Write-Host ("An existing key already exists with value of: " + $Key)

        }
        else {
            $BracketTable.Add($Key, $Value)
        }
    }
}