## Description
Install Systemd service to toggle system wakeup (ACPI) from USB device activity. Limit wakeup to Power buttons and/or other devices.

## System Requirements
* Linux
* systemd

## Why?
Allow or prohibit mouse movement, key presses, controller input, etc., from waking a Linux desktop.

As far as I know, the Linux Desktop Environments (KDE Plasma, GNOME, etc.) do not have any method or guide for this functionality. For example, to achieve the desired result in Windows, open Device Manager > right-click a device > Properties > view the tab for Power Management > Allow this device to wakeup the system.

## How-to
### To download, execute:

        git clone https://github.com/portellam/acpi-sleep

### To install:

        sudo bash installer.bash

#### Usage:

        Usage: bash installer.bash [OPTION]
        Set default behavior of acpi-sleep as Systemd service at startup.

          -h, --help    Print this help and exit.
          -e, --enable  Enable wakeup by USB devices at startup.
          -d, --dsiable Disable wakeup by USB devices at startup.

### To execute

        sudo bash acpi-sleep

#### Usage:

        Usage: bash acpi-sleep [OPTION]
        Toggle system wakeup (ACPI) from USB device activity.

          -h, --help    Print this help and exit.
          -e, --enable  Enable wakeup by USB devices for this session.
          -d, --disable Disable wakeup by USB devices for this session.

## Disclaimer
Should your system not have...
* a Power button
* Wake-on-LAN (with an active Network connection)
* scheduled wakeup times
* Remote administration
* or any other means

Then this script may prevent system resume. Please, evaluate your system before installation.