#!/bin/bash
#
# Filename:     installer.bash#
# Author:       Alex Portell <https://github.com/portellam>
# Description:  Disable ACPI wakeup on USB interfaces' activity.
#

if [[ $( whoami ) != "root" ]]; then
    echo -e "An error occured: User is not sudo/root."
    exit 1
fi

_FILE1="acpi-sleep"
_FILE2="$_FILE1.service"
_DEST1="/usr/local/bin/$_FILE1"
_DEST2="/etc/systemd/system/$_FILE2"

if [[ ! -e "$_FILE1" ]] \
    || [[ ! -e "$_FILE2" ]]; then
    echo -e "An error occured: File(s) missing."
    exit 1
fi

if ! sudo cp "$_FILE1" "$_DEST1" &> /dev/null \
    || ! sudo cp "$_FILE2" "$_DEST2" &> /dev/null; then
    echo -e "An error occured: Failed to copy file(s)."
    exit 1
fi

sudo systemctl enable "$_FILE2" || exit 1
sudo systemctl restart "$_FILE2" || exit 1
sudo systemctl daemon-reload || exit 1
exit 0