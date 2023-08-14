## Description
Install Systemd service to toggle system wakeup (ACPI) from USB device activity. Limit wakeup to Power buttons and/or other devices.

## System Requirements
* Linux
* Systemd

## Why?
Allow or deny mouse movement, key presses, controller input, etc., from waking a Linux desktop.

As far as I know, the Linux Desktop Environments (KDE Plasma, GNOME, etc.) do not have any method or guide for this functionality. For example, this is possible in Windows (#1).

## How-to
### To download, execute:

        git clone https://github.com/portellam/acpi-sleep

### To install:

        sudo bash installer.bash

#### Usage:

        Usage: bash installer.bash [OPTION]
        Set default behavior of acpi-sleep as Systemd service at startup.

          -d, --disable Disable wakeup by USB devices at startup.
          -e, --enable  Enable wakeup by USB devices at startup.
          --uninstall   Uninstall all source files from system, and remove related startup services.
          -h, --help    Print this help and exit.

### To execute

        sudo bash acpi-sleep

#### Usage:

        Usage: bash acpi-sleep [OPTION]
        Toggle system wakeup (ACPI) from USB device activity.

          -d, --disable Disable wakeup by USB devices for this session.
          -e, --enable  Enable wakeup by USB devices for this session.
          -h, --help    Print this help and exit.

## Disclaimer
Default behavior of a system is to allow system wakeup by USB. Therefore, installing the Systemd service to enable wakeup by USB, is not necessary.

Should your system not have...
* a Power button
* Wake-on-LAN (with an active Network connection)
* scheduled wakeup times
* Remote administration
* or any other means

Then this script may prevent system resume. Please, evaluate your system before installation.

## References
#### 1.
<sub>Device Power Management in Windows | **[article (TenForums)](https://web.archive.org/web/20230603175452/https://www.tenforums.com/tutorials/63148-allow-prevent-devices-wake-computer-windows-10-a.html)**</sub>