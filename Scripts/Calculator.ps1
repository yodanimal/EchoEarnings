<#
    .SYNOPSIS
    Logic for wage and tax calculations.

    .DESCRIPTION
    Contains the 2023 U.S. Federal Tax Brackets for a Single Filer

    .PARAMETER inputType
    Are the wages to be calculated based on hourly (H) or an annual salary (S)
    according to the 2023 U.S. Federal Tax Brackets of:
        Limit = 10275,    Rate = 0.10
        Limit = 41775,    Rate = 0.12
        Limit = 89075,    Rate = 0.22
        Limit = 170050,   Rate = 0.24
        Limit = 215950,   Rate = 0.32
        Limit = 539900,   Rate = 0.3
        Limit = MaxValue, Rate = 0.37

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

function Get-CalculatorTaxBrackets() {
    [OutputType([array])]
    $TaxBrackets = @(
        @{ Limit = 10275;   Rate = 0.10 },
        @{ Limit = 41775;   Rate = 0.12 },
        @{ Limit = 89075;   Rate = 0.22 },
        @{ Limit = 170050;  Rate = 0.24 },
        @{ Limit = 215950;  Rate = 0.32 },
        @{ Limit = 539900;  Rate = 0.35 },
        @{ Limit = [decimal]::MaxValue; Rate = 0.37 }
    )
    return $TaxBrackets
}

function Get-CalculatorHoursPerDay() {
    [OutputType([int32])]
    $HoursPerDay = 8
    return $HoursPerDay
}

function Get-CalculatorWorkDaysPerWeek() {
    [OutputType([int32])]
    $DaysPerWeek = 5
    return $DaysPerWeek
}

function Get-CalculatorWeeksPerYear() {
    [OutputType([int32])]
    $WeeksPerYear = 52
    return $WeeksPerYear
}

# Helper function to format currency values
function Format-CalculatorCurrency([decimal]$value) {
    [OutputType([string])]
    $Currency = "{0:C}" -f $value
    return $Currency
}

function Get-CalculateWagesAndTaxes([string]$inputType, [decimal]$value) {
    [OutputType([ordered])]
    $results = @{}

    #Write-Host "Get-CalculateWagesAndTaxes: Type=$($inputType), Value=$($value)"

    # Calculate annual salary and hourly wage
    if ($inputType -eq 'H') {
        $hourlyWage = $value
        $annualSalary = $hourlyWage * (Get-CalculatorHoursPerDay) * (Get-CalculatorWorkDaysPerWeek) * (Get-CalculatorWeeksPerYear)
    } else {
        $annualSalary = $value
        $hourlyWage = $annualSalary / ((Get-CalculatorHoursPerDay) * (Get-CalculatorWorkDaysPerWeek) * (Get-CalculatorWeeksPerYear))
    }

    # Initialize tax calculation variables
    $taxOwed = 0
    $remainingSalary = $annualSalary

    # Calculate tax owed based on brackets
    foreach ($bracket in (Get-CalculatorTaxBrackets)) {
        if ($remainingSalary -gt 0) {
            $taxableAmount = [Math]::Min($remainingSalary, $bracket.Limit)
            $taxOwed += $taxableAmount * $bracket.Rate
            $remainingSalary -= $taxableAmount
        }
    }

    # Bi-weekly paycheck calculation
    $biWeeklyPaycheck = $annualSalary / ((Get-CalculatorWeeksPerYear) / 2)

    # After-tax income calculation
    $afterTaxIncome = $annualSalary - $taxOwed

    # After-tax bi-weekly paycheck
    $afterTaxBiWeeklyPaycheck = $afterTaxIncome / ((Get-CalculatorWeeksPerYear) / 2)

    # return results for display as ordered dictionary
    $results['Annual Salary (Before Tax)'] = $(Format-CalculatorCurrency $annualSalary)
    $results['Annual Salary (After Tax)'] = $(Format-CalculatorCurrency $afterTaxIncome)
    $results['Hourly Wage'] = $(Format-CalculatorCurrency $hourlyWage)
    $results['Bi-Weekly Paycheck (Before Tax)'] = $(Format-CalculatorCurrency $biWeeklyPaycheck)
    $results['Bi-Weekly Paycheck (After Tax)'] = $(Format-CalculatorCurrency $afterTaxBiWeeklyPaycheck)

    return $results
}

#Export-ModuleMember -Function Get-CalculateWagesAndTaxes
