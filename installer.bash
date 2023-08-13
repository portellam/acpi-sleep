#!/bin/bash/env bash

# Filename:     installer.bash
# Author:       Alex Portell <https://github.com/portellam>
# Description:  Install Systemd service to toggle system wakeup (ACPI) from USB device activity.
#

# <params>
  SAVEIFS="${IFS}"
  IFS=$'\n'
  PREFIX_PROMPT="$( basename "${0}" ): "
  PREFIX_ERROR="${PREFIX_PROMPT}An error occurred: "

  FILE1="acpi-sleep"
  FILE2="${FILE1}.service"
  DEST1="/usr/local/bin/${FILE1}"
  DEST2="/etc/systemd/system/${FILE2}"
# </params>

# <traps>
  trap 'catch' ERR
# </traps>

# <functions>
  function main
  {
    if ! disable_wakeup_for_all_interfaces; then
      enable_wakeup_for_all_interfaces
      return 1
    fi
  }

  function catch {
    IFS="${SAVEIFS}"
    print_to_log "${PREFIX_PROMPT}Failed execution."
    return 1
  }

  function is_file_missing
  {
    if [[ ! -e "${FILE1}" ]] \
    || [[ ! -e "${FILE2}" ]]; then
      print_to_log "An error occured: File(s) missing."
      return 1
    fi
  }

  function is_user_superuser
  {
    if [[ $( whoami ) != "root" ]]; then
     print_to_log "${PREFIX_ERROR}User is not sudo or root."
      return 1
    fi
  }

  function print_to_log
  {
    echo -e "${1}" >&2
  }




if ! sudo cp "${FILE1}" "${DEST1}" &> /dev/null \
  || ! sudo cp "${FILE2}" "${DEST2}" &> /dev/null; then
  print_to_log "An error occured: Failed to copy file(s)."
  exit 1
fi

sudo systemctl enable "${FILE2}" || exit 1
sudo systemctl restart "${FILE2}" || exit 1
sudo systemctl daemon-reload || exit 1
exit 0