# Main.ps1
# This script is the entry point of the application.
# It allows the user to choose between the console and GUI interfaces.

# Run the GUI or Console script based on user choice
$interfaceMode = Read-Host "Enter 'C' for Console Interface or 'G' for GUI Interface"

if ($interfaceMode -eq 'C') {
    # Console Interface
    # Import scripts for console-based interaction
    . .\Scripts\InputHandler.ps1
    . .\Scripts\Calculator.ps1
    . .\Scripts\OutputHandler.ps1

    # Get input type and values
    $inputType, $value = Get-UserInput

    # Calculate wages and taxes
    $results = CalculateWagesAndTaxes -inputType $inputType -value $value
    Write-Host "`nResults"

    # Output the results
    Show-Results -results $results
}
elseif ($interfaceMode -eq 'G') {
    # GUI Interface
    # Run the GUI script
    . .\GUI\GUI.ps1
}
else {
    Write-Host "Invalid input. Please enter 'C' for Console or 'G' for GUI."
}
