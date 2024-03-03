# PODE Web App Server

Start-PodeServer {
    # Server Logic
    Add-PodeEndpoint -Address localhost -Port 8081 -Protocol Http

    Add-PodeRoute -Method Get -Path "/" -ScriptBlock {
        Write-PodeHtmlResponse -Value '<h1>Hello, World!</h1>'
    }

}