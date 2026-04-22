# 🦆 USB Rubber Ducky Payload Collection

## Overview

This repository contains a collection of USB Rubber Ducky payloads developed for demonstration, learning, and controlled lab environments. The payloads showcase different techniques such as automation, user interaction, system inventory collection, and script execution via HID injection.

The project is designed to illustrate both the capabilities and risks of keystroke injection devices in a clear and structured way.

---

## 📂 Repository Structure

### 🎭 Prank Payload

A user-facing payload that launches visual and audio effects.

**Features:**

* Text-to-speech announcements
* Popup interaction windows
* Moving/animated UI elements
* Volume manipulation

**Purpose:**
Demonstrates how HID injection can control user experience and system behavior in real time.

---

### 🌐 Open Google Slideshow

A simple payload that opens a browser and navigates to a specified Google Slides presentation.

**Features:**

* Launches browser via Run dialog
* Navigates to a predefined URL

**Purpose:**
Used for demonstrations and presentations to quickly display content during a live demo.

---

### 📊 Recon Payload (Endpoint Snapshot)

A structured PowerShell-based inventory script that collects system information and outputs a formatted report.

**Collected Data Includes:**

* Host information (OS, uptime, CPU, RAM)
* Disk usage
* Network configuration (local IP, gateway)
* PowerShell version
* Local users and sessions
* Running processes (selected watchlist)
* Installed software (top entries)
* Windows Defender status
* Basic user directory summary

**Output:**

* Generates a readable report (`Recon.txt`)
* Opens automatically in Notepad

**Purpose:**
Demonstrates how quickly system context can be gathered using native tools.

---

### ⚠️ Reverse Shell

This portion of the repository is included strictly for **educational and defensive awareness purposes**.

It demonstrates concepts such as:

* obfuscation techniques
* randomized variable generation
* staged command construction
* background execution behavior

**Important:**

* Not intended for execution
* Included to understand how such payloads are structured
* Useful for recognizing patterns in security monitoring and detection

---

## 🛠 Requirements

* USB Rubber Ducky (DuckyScript 3.0)
* PayloadStudio (v1.3.0 or newer)
* Windows target environment (primary)
* PowerShell enabled

---

## 🚀 Usage

1. Encode the desired payload using PayloadStudio
2. Load onto the USB Rubber Ducky
3. Insert into a test system in a controlled environment
4. Observe behavior based on payload type

---

## ⚠️ Ethical Use Disclaimer

These payloads are intended for:

* educational purposes
* lab environments
* authorized testing only

Do not use these scripts on systems without explicit permission.

Unauthorized use may violate laws and institutional policies.

---

## 🎯 Learning Objectives

This project demonstrates:

* HID-based attack surfaces
* PowerShell automation via keystroke injection
* differences between benign and high-risk payloads
* importance of user awareness and endpoint security

---

## 📌 Notes

* Some payloads may be flagged by antivirus or endpoint protection tools
* Behavior may vary based on system configuration
* Timing delays may need adjustment depending on target performance

---

## 👤 Author

Samantha Butler
Mercer University – Cybersecurity / Information Science

---

## 📚 Credits

This project incorporates ideas and references from various open-source repositories and community resources related to:

* USB Rubber Ducky payload development
* PowerShell scripting techniques
* Windows system enumeration methods

Credited:
 - cribbit -- Hey! Got Any Grapes
 - Alef -- Exfiltrate Process Info
 - 0i41E -- Reverse Ducky
 - Alef -- Try to Catch Me
 - P-ict0 -- Max Volume Rickroll
 - cribbit -- Desktop Duck
 - I am Jakoby -- Tree of Knowledge
 - I am Jakoby -- We-Found-You
 - LulzAnarchyAnon -- You-Have-Been-Quaked-2.0
