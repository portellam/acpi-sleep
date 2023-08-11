## Description
Disable system (ACPI) wakeup from USB device or interface activity.

## System Requirements
* Linux
* systemd

## Why?
* Disable system wakeup (from suspend) whenever a mouse is moved, or key is pressed.
* Limit system wakeup to Power buttons or other interfaces and devices.

## How-to
### To install:

        sudo bash acpi-sleep.bash

## Disclaimer
Should your system not have...
* a Power button
* Wake-on-LAN (with an active Network connection)
* scheduled wakeup times
* Remote administration
* or any other means
Then this script may prevent system resume. Please, assess your system before installation.
