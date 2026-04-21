#!/usr/bin/env python3
import os
import re
import json
import base64
import gzip

JSON_FILE = "input.json"
HTML_FILE = "index.html"
OUTPUT_FILE = "output.txt"


def decode_base64_gzip(b64_text: str) -> str:
    """
    FUNCION: Decodes a Base64 string containing GZIP data.
    - Removes whitespace.
    - If empty, returns an empty string.
    - Attempts to Base64-decode and GZIP-decompress the data.
    - Returns UTF-8 text or a formatted error message.
    """
    b64_text = b64_text.strip()
    if not b64_text:
        return ""
    try:
        gz_bytes = base64.b64decode(b64_text)
        text = gzip.decompress(gz_bytes).decode("utf-8", errors="replace")
        return text
    except Exception as e:
        return f"[ERROR] Could not decode: {b64_text[:50]}... ({e})"


def process_json(path: str) -> list[str]:
    """
    Reads the exported JSON and extracts all texts that are Base64-GZIP strings (starting at H4SI).
    Returns a list of the decoded texts, in the order in which they appear.
    """
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    decoded_lines: list[str] = []

    messages = data.get("messages", [])
    for msg in messages:
        text_field = msg.get("text")
        candidates: list[str] = []

        if isinstance(text_field, str):
            candidates.append(text_field)
        elif isinstance(text_field, list):
            for part in text_field:
                if isinstance(part, dict):
                    t = part.get("text")
                    if isinstance(t, str):
                        candidates.append(t)

        for cand in candidates:
            cand = cand.strip()
            if cand.startswith("H4sI"):
                decoded = decode_base64_gzip(cand)
                if decoded:
                    decoded_lines.append(decoded)

    return decoded_lines


def process_html(path: str) -> list[str]:
    """
    Reads the exported HTML and searches for all strings that resemble our Base64-Gzip (H4SI...).
    Returns a list of decoded texts in the order in which they appear.
    """
    with open(path, "r", encoding="utf-8") as f:
        html = f.read()

   
    pattern = re.compile(r"(H4sIA[0-9A-Za-z+/=]+)")
    decoded_lines: list[str] = []

    for match in pattern.finditer(html):
        b64_text = match.group(1).strip()
        decoded = decode_base64_gzip(b64_text)
        if decoded:
            decoded_lines.append(decoded)

    return decoded_lines


def main():
    input_path = None
    mode = None  # "JSON" Or "HTML"

    if os.path.exists(JSON_FILE):
        input_path = JSON_FILE
        mode = "json"
    elif os.path.exists(HTML_FILE):
        input_path = HTML_FILE
        mode = "html"
    else:
        print(f"I didn't find {JSON_FILE} or {HTML_FILE} in this folder.")
        return

    if mode == "json":
        decoded_lines = process_json(input_path)
    else:
        decoded_lines = process_html(input_path)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f_out:
        for line in decoded_lines:
            f_out.write(line)
            if not line.endswith("\n"):
                f_out.write("\n")

    print(f"Processed {input_path} -> {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
