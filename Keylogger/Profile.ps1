function Send-Telegram {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    $tg_token   = "YOUR_BOT_TOKEN"
    $tg_chat_id = "YOUR_CHAT_ID"

    # Ensure TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # URL encode message (VERY important)
    $encodedMessage = [System.Web.HttpUtility]::UrlEncode($Message)

    $uri = "https://api.telegram.org/bot$tg_token/sendMessage"

    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body @{
            chat_id = $tg_chat_id
            text    = $encodedMessage
        }

        return $response
    }
    catch {
        Write-Error "Telegram send failed: $_"
    }
}
