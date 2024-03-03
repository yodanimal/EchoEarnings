<#
    .SYNOPSIS
    Show a web interface for Echo Earnings

    .DESCRIPTION
    To start the server do the following:
        PS> cd webapp
        PS> Import-Module Pode.Web 
        PS> Get-Module -ListAvailable Pode.Web 
        PS> ./server.ps1

    or alternatively:
        PS> cd webapp
        PS> pode start

    Updated are not instant. 
        PS> Ctrl+C  # Terminate Pode web app and run .\server.ps1 to view changes

    Pode -Dev Mode
        PS> Start-PodeServer -DevMode
        Automatically refreshes routes, middleware, and endpoints for development changes.


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

# see https://devblogs.microsoft.com/scripting/incorporating-pipelined-input-into-powershell-functions/
function Get-FormInputAndCalculate([string]$InputType, [string]$InputValue) {
    [OutputType([ordered])]
    $OutputResults = $null

    if ($null -ne $InputType -and $InputType -notmatch '^\s*$' -and
        $null -ne $InputValue -and $InputValue -notmatch '^\s*$') {

        # Write-Host "Get-FormInputAndCalculate: Type=$($InputType), Value=$($InputValue)"

        try {
            $OutputResults = Invoke-LocalScript 'WebCalculator.ps1' $InputType $InputValue

            # using -OutVariable requires an array so just use the first element
            $ResultData = Get-ResultsAsTableData $OutputResults[0]

            Update-PodeWebText -Id 'ResultsTitle' -Value 'Results'
            $ResultData | Update-PodeWebTable -Name 'OutputTable' -TotalItemCount 5
        } catch {
            Write-Host "ERROR:" -BackgroundColor Red -ForegroundColor White
            Write-Host $_
        }
    }

    return $OutputResults
}

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http

    # see https://badgerati.github.io/Pode.Web/Functions/Utilities/Use-PodeWebTemplates/
    Use-PodeWebTemplates -Title 'EchoEarnings' -Theme Dark -Security None

    Set-PodeWebHomePage -Layouts @(
        # see https://badgerati.github.io/Pode.Web/Functions/Layouts/New-PodeWebHero/
        New-PodeWebHero -Title 'Calculate your current or desired Salary' -Message 'This site calculates wages and taxes based on the 2023 US Tax Brackets' -Content @(
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
            New-PodeWebTable -Name 'OutputTable' -NoExport -NoRefresh -NoAuthentication -Compact
        )
    )
}