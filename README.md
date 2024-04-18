# ACPI Sleep
### v1.0.0
Toggle wakeup by ACPI of a Linux machine from USB device activity. Limit wakeup to Power buttons and/or other devices. `systemd` service.

**[Latest release](https://github.com/portellam/acpi-sleep/releases/latest) | [View master branch...](https://github.com/portellam/acpi-sleep/tree/master)**

## Table of Contents
- [Why?](#why)
- [Download](#download)
- [Host Requirements](#host-requirements)
- [Usage](#usage)
  - [1. `installer.bash`](#1-installerbash)
  - [2. `acpi-sleep`](#2-acpi-sleep)
- [Disclaimer](#disclaimer)
- [Contact](#contact)

## Why?
Allow or deny mouse movement, key presses, controller input, etc., from waking a Linux desktop.

As far as I know, the Linux desktop environments (KDE Plasma, GNOME, etc.) do not have any method or guide for this functionality. However, this is accessible to desktop users in [Microsoft Windows](https://web.archive.org/web/20230603175452/https://www.tenforums.com/tutorials/63148-allow-prevent-devices-wake-computer-windows-10-a.html).

### Download
- To download this script, you may:
  - Download the ZIP file:
    1. Viewing from the top of the repository's (current) webpage, click the green `<> Code ` drop-down icon.
    2. Click `Download ZIP`. Save this file.
    3. Open the `.zip` file, then extract its contents.

  - Clone the repository:
    1. Open a Command Line Interface (CLI).
      - Open a console emulator (for Debian systems: Konsole).
      - Open a existing console: press `CTRL` + `ALT` + `F2`, `F3`, `F4`, `F5`, or `F6`.
        - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
        - `F1` is reserved for debug output of the Linux kernel.
        - `F7` is reserved for video output of the desktop environment.
        - `F8` and above are unused.

    2. Change your directory to your home folder or anywhere safe: `cd ~`
    3. Clone the repository: `git clone https://www.github.com/portellam/acpi-sleep`

- To make this script executable, you must:
  1. Open the CLI (see above).
  2. Go to the directory of where the cloned/extracted repository folder is: `cd name_of_parent_folder/acpi-sleep/`
  3. Make the installer script file executable: `chmod +x installer.bash`
    - Do **not** make any other script files executable. The installer will perform this action.
    - Do **not** make any non-script file executable. This is not necessary and potentially dangerous.

### Host Requirements
- `systemd` for system services.

### Usage
#### 1. `installer.bash`
- From within the project folder, execute: `sudo bash installer.bash`

```
  -d, --disable Disable wakeup by USB devices at startup.
  -e, --enable  Enable wakeup by USB devices at startup.
  --uninstall   Uninstall all source files from system, and remove related startup services.
  -h, --help    Print this help and exit.
```

#### 2. `acpi-sleep`
- Execute the installer: `sudo bash installer.bash`
- Or, from any folder execute: `sudo bash acpi-sleep`
  - The CLI's shell (bash) should recognize that the script file is located in `/usr/local/bin`.

```
  -d, --disable Disable wakeup by USB devices for this session.
  -e, --enable  Enable wakeup by USB devices for this session.
  -h, --help    Print this help and exit.
```

## Disclaimer
Default behavior of a system is to allow system wakeup by USB. Therefore, installing the Systemd service to enable wakeup by USB, is not necessary.

Should your system not have...
- a Power button
- Wake-on-LAN (with an active Network connection)
- scheduled wakeup times
- Remote administration
- etc.

then this script may prevent system resume.
Please, evaluate your system before installation.

### Contact
Did you encounter a bug? Do you need help? Notice any dead links? Please contact by [raising an issue](https://github.com/portellam/acpi-sleep/issues) with the project itself.