# InputHandler.ps1
# Manages user input and validation.

enum PromptDataType {
    Choice = 0
    Decimal = 1
}

function Get-HourlyWageValue() {
    [OutputType([string])]
    $Value = 'H'
    return $Value
}

function Get-SalaryWageValue() {
    [OutputType([string])]
    $Value = 'S'
    return $Value
}
function Get-UserInput {
    $prompt = "Enter **$(Get-HourlyWageValue)** for hourly wage or **$(Get-SalaryWageValue)** for salary"
    $inputType = Get-ValidatedInput $prompt ([PromptDataType]::Choice)
    if ($inputType -eq (Get-HourlyWageValue)) {
        $value = Get-ValidatedInput "Enter your hourly wage" ([PromptDataType]::Decimal)
    } elseif ($inputType -eq (Get-SalaryWageValue)) {
        $value = Get-ValidatedInput "Enter your annual salary" ([PromptDataType]::Decimal)
    }
    return $inputType, $value
}

function Get-ValidatedInput {
    param (
        [string]$prompt,
        [PromptDataType]$type
    )
    do {
        $userInput = Show-InputPromptMessage $prompt
        try {
            if ($type -eq [PromptDataType]::Decimal) {
                [decimal]$validatedInput = $userInput
                return $validatedInput
            } elseif ($type -eq [PromptDataType]::Choice) {
                if ($userInput -ne (Get-HourlyWageValue) -and $userInput -ne (Get-SalaryWageValue)) { throw }
                return $userInput
            }
        } catch {
            Show-ErrorMessage "Invalid input. Please enter a valid number for '$type'."
        }
    } while ($true)
}
