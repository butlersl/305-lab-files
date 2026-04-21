function Send-Telegram {
    param(
        [string]$Message
    )

    $tg_token = "8665518944:AAGN4ncP375c0rNFEsXiaOBN9G-0scYJ2qg"
    $tg_chat_id = "8298670259"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $uri = "https://api.telegram.org/bot$tg_token/sendMessage"

    $encodedMessage = [System.Net.WebUtility]::UrlEncode($Message)

    try {
        Invoke-RestMethod -Uri $uri -Method Post -Body @{
            chat_id = $tg_chat_id
            text    = $encodedMessage
        }
    }
    catch {
        $_ | Format-List * -Force
    }
}
