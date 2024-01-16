# GUI\GUI.ps1
# This script handles the loading and interaction of the WPF GUI.

# Load WPF Assembly
Add-Type -AssemblyName PresentationFramework

# Load XAML for GUI
[xml]$xaml = Get-Content -Path '.\GUI\MainWindow.xaml'
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get GUI elements
$radioHourly = $window.FindName('radioHourly')
$radioSalary = $window.FindName('radioSalary')
$inputValue = $window.FindName('inputValue')
$calculateButton = $window.FindName('calculateButton')
$outputText = $window.FindName('outputText')

# Import the logic scripts from Scripts folder
. .\Scripts\InputHandler.ps1
. .\Scripts\Calculator.ps1
. .\Scripts\OutputHandler.ps1

# Define event handler for the calculate button
$calculateButton.Add_Click({
    # Determine the input type based on which radio button is checked
    $inputType = $radioHourly.IsChecked -eq $true ? 'H' : 'S'

    # Explicitly check the state of radioSalary for clarity
    if ($radioSalary.IsChecked -eq $true) {
        $inputType = 'S'
    }

    # Get the value entered by the user and ensure it's treated as a decimal
    try {
        $value = [decimal]$inputValue.Text
    } catch {
        $outputText.Text = "Please enter a valid numeric value."
        return
    }

    # Calculate wages and taxes based on the input
    $results = CalculateWagesAndTaxes -inputType $inputType -value $value

    # Display the results in the output text box
    $outputText.Text = $results
})

# Show the window
[void]$window.ShowDialog()
