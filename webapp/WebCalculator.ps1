<#
    .SYNOPSIS
    Logic for wage and tax calculations.

    .DESCRIPTION
    Contains the 2023 U.S. Federal Tax Brackets for a Single Filer

    .PARAMETER ttype
    Are the wages to be calculated based on hourly (H) or an annual salary (S)

    .PARAMETER value
    Either and hourly rate value or an annual salary value

    .EXAMPLE
    PS> Get-CalculateWagesAndTaxes H 50
    Annual Salary (Before Tax): $104,000.00
    Bi-Weekly Paycheck (After Tax): $3,328.10
    Hourly Wage: $50.00
    Annual Salary (After Tax): $86,530.50
    Bi-Weekly Paycheck (Before Tax): $4,000.00

    .EXAMPLE
    PS> Get-CalculateWagesAndTaxes S 50000
    Annual Salary (Before Tax): $50,000.00
    Bi-Weekly Paycheck (After Tax): $1,700.21
    Hourly Wage: $24.04
    Annual Salary (After Tax): $44,205.50
    Bi-Weekly Paycheck (Before Tax): $1,923.08
#>

param(
    [Parameter(Mandatory)]
    [string]$type,
    [Parameter(Mandatory)]
    [string]$value
)

. $PSScriptRoot\..\Scripts\Calculator.ps1

$Results = Get-CalculateWagesAndTaxes $type ("{0:F}" -f $value)
$JSON = $Results | ConvertTo-Json -Depth 100
($JSON)
