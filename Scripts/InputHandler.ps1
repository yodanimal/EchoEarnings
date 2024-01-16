# InputHandler.ps1
# Manages user input and validation.

function Get-UserInput {
    $inputType = Get-ValidatedInput "Enter 'H' for hourly wage or 'S' for salary" "choice"
    if ($inputType -eq 'H') {
        $value = Get-ValidatedInput "Enter your hourly wage" "decimal"
    } elseif ($inputType -eq 'S') {
        $value = Get-ValidatedInput "Enter your annual salary" "decimal"
    }
    return $inputType, $value
}

function Get-ValidatedInput {
    param (
        [string]$prompt,
        [string]$type
    )
    do {
        $userInput = Read-Host $prompt
        try {
            if ($type -eq "decimal") {
                [decimal]$validatedInput = $userInput
                return $validatedInput
            } elseif ($type -eq "choice") {
                if ($userInput -ne 'H' -and $userInput -ne 'S') { throw }
                return $userInput
            }
        } catch {
            Write-Host "Invalid input. Please enter a valid number for '$type'."
        }
    } while ($true)
}
