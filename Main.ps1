# Main.ps1
. .\Scripts\OutputHandler.ps1

# User picks: GUI or Console
$interfaceMode = Show-InputPromptMessage "Enter **C** for Console Interface or **G** for GUI Interface"

if ($interfaceMode -eq 'C') {
    # Console Interface
    # Dot-source to InputHandler and Calculator
    . .\Scripts\InputHandler.ps1
    . .\Scripts\Calculator.ps1

    $inputType, $value = Get-UserInput

    # Calculate wages and taxes
    $results = Get-CalculateWagesAndTaxes -inputType $inputType -value $value

    Show-OutputFormattedMessage "**RESULTS**"

    # Output the results
    foreach ($KeyValuePair in $results.GetEnumerator()) {
        $prompt = $KeyValuePair.Name
        $output = $KeyValuePair.Value
        Show-OutputMessage $prompt $output
    }
}
elseif ($interfaceMode -eq 'G') {
    # GUI Interface
    # Run GUI script
    if ($IsWindows) {
        . .\GUI\GUI.ps1
    } else {
        Show-ErrorMessage "Only Microsoft Windows is supported for GUI mode"
    }
}
else {
    Show-ErrorMessage "Invalid input. Please enter 'C' for Console or 'G' for GUI."
}

<#
    you should do this here
#>
