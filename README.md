## Description
Disable ACPI wakeup on USB interfaces' activity.

## System Requirements
* Linux
* systemd

## Why?
* Disable system wakeup (from suspend) whenever a mouse is moved, or keyboard pressed.
* Limit system wakeup from Power buttons or other interfaces and devices.

## Disclaimer
Should your system not have...
* a Power button
* Wake-on-LAN (with an active Network connection)
* scheduled wakeup times
* Remote administration
* or any other means to resume from system suspend

Then this script may obfuscate or prevent system resume. Please, assess your system setup, and be careful.

*Why yes this Works on my Machine, how could you tell?*