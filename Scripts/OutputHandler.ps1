# Scripts\OutputHandler.ps1
# This script is responsible for formatting and displaying the results.

function Show-ErrorMessage([string]$Message) {
    Write-Host "ERROR:" -NoNewline -BackgroundColor DarkRed -ForegroundColor White
    Write-Host " $($Message)" -ForegroundColor Red
}


function Show-InputPromptMessage([string]$Message) {
    # see https://rogierdijkman.medium.com/use-bold-font-in-write-host-b4b8155a8208
    $FormattedMessage = (ConvertFrom-Markdown -InputObject $Message -AsVT100EncodedString).VT100EncodedString
    Read-Host $FormattedMessage.Trim()
}

function Show-OutputMessage([string]$Message, [string]$Value) {
    # see https://rogierdijkman.medium.com/use-bold-font-in-write-host-b4b8155a8208
    if ($Value) {
        Write-Host $Message -NoNewline -BackgroundColor DarkBlue -ForegroundColor White
        Write-Host ": $($Value)" -ForegroundColor DarkBlue
    } else {
        Show-OutputFormattedMessage $Message
    }
}

function Show-OutputFormattedMessage([string]$Message) {
    # see https://rogierdijkman.medium.com/use-bold-font-in-write-host-b4b8155a8208
    $FormattedMessage = (ConvertFrom-Markdown -InputObject $Message -AsVT100EncodedString).VT100EncodedString
    Write-Host $FormattedMessage -ForegroundColor DarkBlue
}

    # Future Enhancement:
    # This function can be expanded to include more sophisticated formatting
    # or even exporting results to a file or different output medium.