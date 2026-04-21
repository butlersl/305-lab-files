function Send-Telegram {
        [CmdletBinding()]
        param(
            [Parameter()]
            [string] $Message
        )    
        $tg_token="8665518944:AAGN4ncP375c0rNFEsXiaOBN9G-0scYJ2qg"
        $tg_chat_id="8298670259"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($tg_token)/sendMessage?chat_id=$($tg_chat_id)&text=$($Message)&parse_mode=html" 
        return $Response    
 }
