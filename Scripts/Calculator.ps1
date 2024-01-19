# Calculator.ps1
# This script contains the logic for wage and tax calculations.

# Constants
$hoursPerDay = 8
$daysPerWeek = 5
$weeksPerYear = 52

# U.S. Federal Tax Brackets for a Single Filer (Example for 2023)
$taxBrackets = @(
    @{ Limit = 10275;   Rate = 0.10 },
    @{ Limit = 41775;   Rate = 0.12 },
    @{ Limit = 89075;   Rate = 0.22 },
    @{ Limit = 170050;  Rate = 0.24 },
    @{ Limit = 215950;  Rate = 0.32 },
    @{ Limit = 539900;  Rate = 0.35 },
    @{ Limit = [decimal]::MaxValue; Rate = 0.37 }
)

function CalculateWagesAndTaxes([string]$inputType, [decimal]$value) {
    [OutputType([ordered])]
    $results = @{}

    # Calculate annual salary and hourly wage
    if ($inputType -eq 'H') {
        $hourlyWage = $value
        $annualSalary = $hourlyWage * $hoursPerDay * $daysPerWeek * $weeksPerYear
    } else {
        $annualSalary = $value
        $hourlyWage = $annualSalary / ($hoursPerDay * $daysPerWeek * $weeksPerYear)
    }

    # Initialize tax calculation variables
    $taxOwed = 0
    $remainingSalary = $annualSalary

    # Calculate tax owed based on brackets
    foreach ($bracket in $taxBrackets) {
        if ($remainingSalary -gt 0) {
            $taxableAmount = [Math]::Min($remainingSalary, $bracket.Limit)
            $taxOwed += $taxableAmount * $bracket.Rate
            $remainingSalary -= $taxableAmount
        }
    }

    # Bi-weekly paycheck calculation
    $biWeeklyPaycheck = $annualSalary / ($weeksPerYear / 2)

    # After-tax income calculation
    $afterTaxIncome = $annualSalary - $taxOwed

    # After-tax bi-weekly paycheck
    $afterTaxBiWeeklyPaycheck = $afterTaxIncome / ($weeksPerYear / 2)

    # return results for display as ordered dictionary
    $results['Annual Salary (Before Tax)'] = $(Format-Currency $annualSalary)
    $results['Annual Salary (After Tax)'] = $(Format-Currency $afterTaxIncome)
    $results['Hourly Wage'] = $(Format-Currency $hourlyWage)
    $results['Bi-Weekly Paycheck (Before Tax)'] = $(Format-Currency $biWeeklyPaycheck)
    $results['Bi-Weekly Paycheck (After Tax)'] = $(Format-Currency $afterTaxBiWeeklyPaycheck)

    return $results
}

# Helper function to format currency values
function Format-Currency {
    param ([decimal]$value)
    return "{0:C}" -f $value
}
