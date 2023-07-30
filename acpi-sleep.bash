#!/bin/bash
#
# Filename:     acpi-sleep.bash
# Author:       Alex Portell <https://github.com/portellam>
# Description:  Installs required files.
#

if [[ $( whoami ) != "root" ]]; then
  echo -e "An error occured: User is not sudo/root."
  exit 1
fi

FILE1="acpi-sleep"
FILE2="$FILE1.service"
DEST1="/usr/local/bin/$FILE1"
DEST2="/etc/systemd/system/$FILE2"

if [[ ! -e "$FILE1" ]] \
  || [[ ! -e "$FILE2" ]]; then
  echo -e "An error occured: File(s) missing."
  exit 1
fi

if ! sudo cp "$FILE1" "$DEST1" &> /dev/null \
  || ! sudo cp "$FILE2" "$DEST2" &> /dev/null; then
  echo -e "An error occured: Failed to copy file(s)."
  exit 1
fi

sudo systemctl enable "$FILE2" || exit 1
sudo systemctl restart "$FILE2" || exit 1
sudo systemctl daemon-reload || exit 1
exit 0