<img align="left" height="100" alt="I SLEEP" src="./media/i-sleep.png"/>
<br>

# ACPI Sleep

### v1.1.0

Allow or deny device(s) to wake-up a Linux machine from a suspended state.
Limit wake-up to matched input devices (Power, PCI, Plug-and-Play (PnP), FireWire, USB, etc.).

## [💾 Download](#-2-download)

#### View this repository on [Codeberg][01], [GitHub][02].

[01]: https://codeberg.org/portellam/acpi-sleep
[02]: https://github.com/portellam/acpi-sleep

##

## Table of Contents
- [❓ 1. Why?](#-1-why)
- [✅ 2. Requirements](#-2-requirements)
- [💾 3. Download](#-3-download)
- [❓ 4. Usage](#-4-usage)
  - [4.1. The Command Interface (CLI) or Terminal](#41-the-command-interface-cli-or-terminal)
  - [4.2. Verify Installer is Executable](#42-verify-script-is-executable)
  - [4.3. Installer](#43-installer)
  - [4.4. Executable](#44-executable)
- [⚠️ 5. Disclaimer](#-5-disclaimer)
- [☎️ 6. Contact](#-6-contact)
- [🌐 7. References](#-7-references)

## Contents

### ❓ 1. Why?

By default, some Linux distributions do not have easy access to toggle which
**Advanced Configuration and Power Interface (ACPI)** [<sup>\[1\]</sup>](#1)
devices may wake-up the Host machine; *unlike in Microsoft Windows, there is no*
*easy method to do so.* [<sup>\[2\]</sup>](#2)

**What does *ACPI Sleep* do?** A script to blacklist/whitelist specified devices
and/or device groups from ACPI wake-up of the Host; *easily allow or deny mouse*
*movement, key presses, controller input, etc. from disturbing the sleep of a*
*Host machine.* Devices include Plug-and-Play (PnP) devices
(FireWire, USB, or anything hot-pluggable) and/or PCI devices
(expansion cards, graphics, networking, USB controllers, etc.).

### ✅ 2. Requirements

- **Operating System (OS):**
  - **Linux.**
  - ***BSD*** *is not supported*.

- `lsusb` to parse USB PnP devices.
- `systemd` for system services.

### 💾 3. Download

- Download the Latest Release: [Codeberg][31], [GitHub][32]

- Download the `.zip` file:

  - From the webpage

    1. Viewing from the top of the repository's (current) webpage, click the
       drop-down icon:

       - `···` on Codeberg.
       - `<> Code ` on GitHub.

    2. Click `Download ZIP` and save.
    3. Open the `.zip` file, then extract its contents.

  - From the CLI:

    1. [Open the CLI](#41-the-command-interface-cli-or-terminal).
    2. Download the Latest:

    ```bash
    GH_USER=portellam; \
    GH_REPO=acpi-sleep; \
    GH_BRANCH=master; \
    wget \
      https://github.com/${GH_USER}/${GH_REPO}/archive/refs/heads/${GH_BRANCH}.zip \
      -O "${GH_REPO}-${GH_BRANCH}.zip" \
    && unzip ./"${GH_REPO}-${GH_BRANCH}.zip" \
    && rm ./"${GH_REPO}-${GH_BRANCH}.zip"
    ```

- Clone the repository:

  1. [Open the CLI](#41-the-command-interface-cli-or-terminal).

  2. Change your directory to your home folder or anywhere safe:
     - `cd ~`

  3. Clone the repository:
     - `git clone https://www.codeberg.org/portellam/acpi-sleep`
     - `git clone https://www.github.com/portellam/acpi-sleep`

[31]: https://codeberg.org/portellam/acpi-sleep/releases/latest
[32]: https://github.com/portellam/acpi-sleep/releases/latest

### ❓ 4. Usage

#### 4.1. The Command Interface (CLI) or Terminal

To open a CLI or Terminal:

- Open a console emulator (for Debian systems: Konsole).
- **Linux only:** Open an existing console: press `CTRL` + `ALT` + `F2`,
  `F3`, `F4`, `F5`, or `F6`.

  - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
  - `F1` is reserved for debug output of the Linux kernel.
  - `F7` is reserved for video output of the desktop environment.
  - `F8` and above are unused.

#### 4.2. Verify Installer is Executable

1. Go to the directory where the cloned/extracted repository folder is:
   `cd name_of_parent_folder/acpi-sleep/`

2. Make the installer script file executable: `chmod +x installer.bash`

   - Do **not** make any other script files executable. The installer will
    perform this action.
   - Do **not** make any non-script file executable. This is not necessary and
     potentially dangerous.

#### 4.3. Installer

- **To install,** execute from within the project folder:
  `sudo bash installer.bash`

```
  -h, --help        Print this help and exit.
  -u, --uninstall   Uninstall all source files from system, and remove related
                    startup services.
```

#### 4.4. Executable

- From any folder execute: `sudo acpi-sleep [OPTION]`
  - The CLI's shell (bash) should recognize that the script file is located in
    `/usr/local/bin`.

```
  -h, --help              Print this help and exit.

  -s, --save              Save changes so they persist after restart of the Host
                          machine.

  "--pci STATUS           Get PCI devices and the ACPI wake status of each.
                          STATUS is the state of matched devices. STATUS may be
                          either "enabled", "disabled", or empty (match all).

  "--pnp STATUS           Get Plug-and-Play (PnP) and/or USB devices and the ACPI
                          wake status of each.
                          STATUS is the state of matched devices. STATUS may be
                          either "enabled", "disabled", or empty (match all).

  -b|--blacklist MATCH    Blacklist individual devices and/or PCI devices
                          manually.
                          MATCH is a comma delimited list of keywords, PCI device
                          IDs, and/or IOMMU groups (groups of PCI devices).
                          Keywords include individual or PCI device names and
                          types; PCI device IDs are colon delimited pairs of
                          four-character alphanumeric words; IOMMU groups are
                          positive numbers.

  --blacklist-all         Blacklist all individual devices and PCI devices.

  --blacklist-kbm         Blacklist all individual keyboard-and-mouse (KBM)
                          devices.

  --blacklist-pci         Blacklist all PCI device groups.

  --blacklist-pnp         Whitelist all individual PnP devices and controllers
                          (PCI devices).

  --blacklist-non-kbm     Blacklist all individual non-KBM devices.

  -w|--whitelist MATCH    Whitelist individual devices and/or PCI devices
                          manually.
                          MATCH is a comma delimited list of keywords, PCI device
                          IDs, and/or IOMMU groups (groups of PCI devices).
                          Keywords include individual or PCI device names and
                          types; PCI device IDs are colon delimited pairs of
                          four-character alphanumeric words; IOMMU groups are
                          positive numbers.

  --whitelist-all         Whitelist all individual devices and PCI devices.

  --whitelist-kbm         Whitelist all individual keyboard-and-mouse (KBM)
                          devices.

  --whitelist-pci         Whitelist all PCI device groups.

  --whitelist-pnp         Whitelist all individual PnP devices and controllers
                          (PCI devices).

  --whitelist-non-kbm     Whitelist all individual non-KBM devices.
```

### ⚠️ 5. Disclaimer

Default behavior of a Host machine is to allow system wake-up by PnP. Therefore,
installing *ACPI Sleep* to enable wake-up of devices, *is not necessary.*

**Should your system not have...**
- a Power button.
- Wake-on-LAN (with an active Network connection).
- scheduled wake-up times.
- Remote administration.
- etc.

*...then this script may prevent system resume. Please evaluate your system*
*before installation.*

### ☎️ 6. Contact

Do you need help? Please visit the [Issues][61] page.

[61]: https://github.com/portellam/acpi-sleep/issues


### 🌐 7. References

#### 1.

&nbsp;&nbsp;**ACPI**. Wikipedia. Accessed June 4, 2025.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://en.wikipedia.org/wiki/ACPI.</sup>

#### 2.

&nbsp;&nbsp;**How to Allow or Prevent Devices to Wake Computer in Windows 10**. TenForums.
Accessed June 4, 2025.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://web.archive.org/web/20230603175452/https://www.tenforums.com/tutorials/63148-allow-prevent-devices-wake-computer-windows-10-a.html.</sup>

##

#### Click [here](#acpi-sleep) to return to the top of this document.