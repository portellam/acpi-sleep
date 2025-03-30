# ACPI Sleep
### v1.0.1
Toggle wakeup by ACPI of a Linux machine from USB device activity. Limit wakeup to Power buttons and/or other devices. `systemd` service.

## [Download](#2-download)
#### View this repository on [Codeberg][01], [GitHub][02].
[01]: https://codeberg.org/portellam/acpi-sleep
[02]: https://github.com/portellam/acpi-sleep
##

## Table of Contents
- [1. Why?](#1-why)
- [2. Download](#2-download)
- [3. Host Requirements](#3-host-requirements)
- [4. Usage](#4-usage)
  - [4.1. Verify Installer is Executable](#41-verify-installer-is-executable)
  - [4.1. `installer.bash`](#42-installerbash)
  - [4.2. `acpi-sleep`](#43-acpi-sleep)
- [5. Disclaimer](#5-disclaimer)
- [6. Contact](#6-contact)

## 1. Why?
Allow or deny mouse movement, key presses, controller input, etc., from waking a Linux desktop.

As far as I know, the Linux desktop environments (KDE Plasma, GNOME, etc.) do not have any method or guide for this functionality. However, this is accessible to desktop users in [Microsoft Windows](https://web.archive.org/web/20230603175452/https://www.tenforums.com/tutorials/63148-allow-prevent-devices-wake-computer-windows-10-a.html).

### 2. Download
- Download the Latest Release:&ensp;[Codeberg][51], [GitHub][52]

- Download the `.zip` file:
    1. Viewing from the top of the repository's (current) webpage, click the
        drop-down icon:
        - `···` on Codeberg.
        - `<> Code ` on GitHub.
    2. Click `Download ZIP` and save.
    3. Open the `.zip` file, then extract its contents.

- Clone the repository:
    1. Open a Command Line Interface (CLI) or Terminal.
        - Open a console emulator (for Debian systems: Konsole).
        - **Linux only:** Open an existing console: press `CTRL` + `ALT` + `F2`,
        `F3`, `F4`, `F5`, or `F6`.
            - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
            - `F1` is reserved for debug output of the Linux kernel.
            - `F7` is reserved for video output of the desktop environment.
            - `F8` and above are unused.
    2. Change your directory to your home folder or anywhere safe:
        - `cd ~`
    3. Clone the repository:
        - `git clone https://www.codeberg.org/portellam/auto-xorg`
        - `git clone https://www.github.com/portellam/auto-xorg`

[51]: https://codeberg.org/portellam/auto-xorg/releases/latest
[52]: https://github.com/portellam/auto-xorg/releases/latest

### 3. Host Requirements
- `systemd` for system services.

### 4. Usage
#### 4.1. Verify Installer is Executable
1. Open the CLI (see [Download](#2-download)).

2. Go to the directory of where the cloned/extracted repository folder is:
`cd name_of_parent_folder/acpi-sleep/`

3. Make the installer script file executable: `chmod +x installer.bash`
    - Do **not** make any other script files executable. The installer will perform
  this action.
    - Do **not** make any non-script file executable. This is not necessary and
  potentially dangerous.

#### 4.2. `installer.bash`
- From within the project folder, execute: `sudo bash installer.bash`

```
  -d, --disable Disable wakeup by USB devices at startup.
  -e, --enable  Enable wakeup by USB devices at startup.
  --uninstall   Uninstall all source files from system, and remove related startup services.
  -h, --help    Print this help and exit.
```

#### 4.3. `acpi-sleep`
- Execute the installer: `sudo bash installer.bash`
- Or, from any folder execute: `sudo bash acpi-sleep`
  - The CLI's shell (bash) should recognize that the script file is located in `/usr/local/bin`.

```
  -d, --disable Disable wakeup by USB devices for this session.
  -e, --enable  Enable wakeup by USB devices for this session.
  -h, --help    Print this help and exit.
```

## 5. Disclaimer
Default behavior of a system is to allow system wakeup by USB. Therefore, installing the Systemd service to enable wakeup by USB, is not necessary.

Should your system not have...
- a Power button
- Wake-on-LAN (with an active Network connection)
- scheduled wakeup times
- Remote administration
- etc.

then this script may prevent system resume.
Please, evaluate your system before installation.

### 6. Contact
Wish to recommend a project? Do you need help? Please visit the [Issues][61] page.

[61]: https://github.com/portellam/acpi-sleep/issues
##

#### Click [here](#acpi-sleep) to return to the top of this document.