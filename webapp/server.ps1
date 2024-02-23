Import-Module Pode.Web
. ../Scripts/Calculator.ps1

function Get-ResultsDump([System.Collections.Specialized.OrderedDictionary]$Results) {
    foreach ($KeyValuePair in $Results.GetEnumerator()) {
        $Key = $KeyValuePair.Name
        $Value = $KeyValuePair.Value
        Write-Host "Get-ResultsDump: Key=$($Key), Value=$($Value)"
    }
}

# see https://devblogs.microsoft.com/scripting/incorporating-pipelined-input-into-powershell-functions/
function Get-FormInputAndCalculate([string]$InputType, [string]$InputValue) {
    [OutputType([ordered])]
    $OutputResults = $null

    if ($null -ne $InputType -and $InputType -notmatch '^\s*$' -and
        $null -ne $InputValue -and $InputValue -notmatch '^\s*$') {

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
            Write-Host $_
        }
    }

    return $OutputResults
}

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http

    # see https://badgerati.github.io/Pode.Web/Functions/Utilities/Use-PodeWebTemplates/
    Use-PodeWebTemplates -Title 'EchoEarnings' -Theme Dark

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
            New-PodeWebTable -Name 'OutputTable'
        )
    )
}