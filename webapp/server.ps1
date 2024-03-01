<<<<<<< HEAD
<#
    .SYNOPSIS
    Show a web interface for Echo Earnings

    .DESCRIPTION
    To start the server do the following:
        PS> cd webapp
        PS> Import-Module Pode.Web
        PS> ./server.ps1

    or alternatively:
        PS> cd webapp
        PS> pode start
#>
Import-Module Pode.Web

function Invoke-LocalScript([string]$ScriptFileName, [string]$Type, [string]$Value) {
    $WebAppLocation = Join-Path -Path (Get-Location) -ChildPath 'webapp'
    $PathToScript = Join-Path -Path $WebAppLocation -ChildPath $ScriptFileName

    Invoke-Expression -Command "$PathToScript -type $Type -value $Value" -OutVariable OutputResults
    # Write-Host "Invoke-LocalScript: Output=<$($OutputResults)>"
 
    return $OutputResults
}

function Get-ResultsAsTableData([string]$Results) {
    [OutputType([ordered])]
    $OutputData = @{}

    $JSON = ConvertFrom-Json $Results -AsHashtable

    # see https://badgerati.github.io/Pode.Web/Tutorials/Elements/Table/#data
    foreach ($Key in $JSON.Keys) {
        $OutputData[$Key] = $JSON[$Key]
        # Write-Host "Get-ResultsAsTableData: Key=$($Key), Value=$($JSON.$Key)"
    }

    return $OutputData
}

=======
Import-Module Pode.Web
. ../Scripts/Calculator

function Get-ResultsDump([System.Collections.Specialized.OrderedDictionary]$Results) {
    foreach ($KeyValuePair in $Results.GetEnumerator()) {
        $Key = $KeyValuePair.Name
        $Value = $KeyValuePair.Value
        Write-Host "Get-ResultsDump: Key=$($Key), Value=$($Value)"
    }
}

$global:CalculationType = $null
$global:CalculationValue = $null

>>>>>>> 2fdc32f (1st pass at web app using Pode.Web)
# see https://devblogs.microsoft.com/scripting/incorporating-pipelined-input-into-powershell-functions/
function Get-FormInputAndCalculate([string]$InputType, [string]$InputValue) {
    [OutputType([ordered])]
    $OutputResults = $null

    if ($null -ne $InputType -and $InputType -notmatch '^\s*$' -and
        $null -ne $InputValue -and $InputValue -notmatch '^\s*$') {

<<<<<<< HEAD
        # Write-Host "Get-FormInputAndCalculate: Type=$($InputType), Value=$($InputValue)"

        try {
            $OutputResults = Invoke-LocalScript 'WebCalculator.ps1' $InputType $InputValue

            # using -OutVariable requires an array so just use the first element
            $ResultData = Get-ResultsAsTableData $OutputResults[0]

            Update-PodeWebText -Id 'ResultsTitle' -Value 'Results'
            $ResultData | Update-PodeWebTable -Name 'OutputTable' -TotalItemCount 5
        } catch {
            Write-Host "ERROR:" -BackgroundColor Red -ForegroundColor White
=======
        $DecimalValue = [decimal]$InputValue
        Write-Host "Get-FormInputAndCalculate: Type=$($InputType), Value=$($DecimalValue)"

        try {
            $OutputResults = Get-CalculateWagesAndTaxes $InputType $DecimalValue
            Get-ResultsDump $OutputResults

            $ResultsTitle = 'Results'
            Update-PodeWebText -Id 'ResultsTitle' -Value $ResultsTitle
            Update-PodeWebTable -Id 'OutputTable' -Data $OutputResults
        } catch {
            Write-Host "ERROR:"
>>>>>>> 2fdc32f (1st pass at web app using Pode.Web)
            Write-Host $_
        }
    }

    return $OutputResults
}

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http

    # see https://badgerati.github.io/Pode.Web/Functions/Utilities/Use-PodeWebTemplates/
<<<<<<< HEAD
    Use-PodeWebTemplates -Title 'EchoEarnings' -Theme Dark -Security None
=======
    Use-PodeWebTemplates -Title 'EchoEarnings' -Theme Dark
>>>>>>> 2fdc32f (1st pass at web app using Pode.Web)

    Set-PodeWebHomePage -Layouts @(
        # see https://badgerati.github.io/Pode.Web/Functions/Layouts/New-PodeWebHero/
        New-PodeWebHero -Title 'Welcome to Echo Earnings' -Message 'This site calculates wages and taxes based on your input' -Content @(
            # see https://badgerati.github.io/Pode.Web/Functions/Elements/New-PodeWebLink/
            New-PodeWebLink -Value 'Access Calculator' -Source '/pages/Salary_Calculator'
        )
    )

    # see https://badgerati.github.io/Pode.Web/Functions/Pages/Add-PodeWebPage/
    Add-PodeWebPage -Name 'Salary Calculator' -Icon 'calculator-variant' -Layouts @(
        # see https://badgerati.github.io/Pode.Web/Functions/Layouts/New-PodeWebCard/
        New-PodeWebCard -Content @(
            # see https://badgerati.github.io/Pode.Web/Functions/Elements/New-PodeWebForm/
            New-PodeWebForm -Name 'Salary Calculator Input' -SubmitText 'Calculate' -ScriptBlock {
                $WebEvent.Data | Out-Host
                if ($null -ne $WebEvent.Data) {
                    $InputType = $null
                    $InputValue = $null
                    foreach ($Key in $WebEvent.Data.Keys) {
                        $KeyValue = $WebEvent.Data[$Key]
                        if ($Key -eq 'InputType') {
                            $InputType = $KeyValue
                        } elseif ($Key -eq 'InputValue') {
                            $InputValue = $KeyValue
                        }
                    }
                    Get-FormInputAndCalculate $InputType $InputValue
                }
            } -Content @(
                # see https://badgerati.github.io/Pode.Web/Functions/Elements/New-PodeWebRadio/
                New-PodeWebRadio -Name 'InputType' -DisplayName 'Input Type' -Required -Options @('H', 'S') -DisplayOptions @('Hourly Wage', 'Annual Salary')
                
                # see https://badgerati.github.io/Pode.Web/Functions/Elements/New-PodeWebTextbox/
                New-PodeWebTextbox -Name 'InputValue' -DisplayName 'Input Value' -Required -Type Text
            )
        )

        # see https://badgerati.github.io/Pode.Web/Functions/Layouts/New-PodeWebCard/
        New-PodeWebCard -Content @(
            # see https://badgerati.github.io/Pode.Web/Functions/Elements/New-PodeWebText/
            New-PodeWebText -Id 'ResultsTitle' -Value $ResultsTitle

            # see https://badgerati.github.io/Pode.Web/Functions/Elements/New-PodeWebTable/
<<<<<<< HEAD
            New-PodeWebTable -Name 'OutputTable' -NoExport -NoRefresh -NoAuthentication -Compact
=======
            New-PodeWebTable -Name 'OutputTable'
>>>>>>> 2fdc32f (1st pass at web app using Pode.Web)
        )
    )
}