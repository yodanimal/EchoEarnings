# InputHandler.ps1
# Manages user input and validation.

enum PromptDataType {
    Choice = 0
    Decimal = 1
}

$HourlyWage = 'H'
$SalaryWage = 'S'

function Get-UserInput {
    $prompt = "Enter **$($HourlyWage)** for hourly wage or **$($SalaryWage)** for salary"
    $inputType = Get-ValidatedInput $prompt ([PromptDataType]::Choice)
    if ($inputType -eq $HourlyWage) {
        $value = Get-ValidatedInput "Enter your hourly wage" ([PromptDataType]::Decimal)
    } elseif ($inputType -eq $SalaryWage) {
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
                if ($userInput -ne $HourlyWage -and $userInput -ne $SalaryWage) { throw }
                return $userInput
            }
        } catch {
            Show-ErrorMessage "Invalid input. Please enter a valid number for '$type'."
        }
    } while ($true)
}
