#!/bin/bash
#
# Author:       Alex Portell <https://github.com/portellam>
# Description:  Disable ACPI wakeup on USB interfaces' activity.
#

if [[ $( whoami ) != "root" ]]; then
    echo -e "User is not sudo/root."
    exit 1
fi

FILE1="acpi-sleep.bash"
FILE2="acpi-sleep.service"
DEST1="/usr/sbin/$FILE1"
DEST2="/etc/systemd/system/$FILE2"

if [[ ! -e $FILE1 || ! -e $FILE2 ]]; then
    echo -e "File(s) missing."
    exit 1
fi

if ! cp $FILE1 $DEST1 || ! cp $FILE2 $DEST2; then
    echo -e "Write failure."
    exit 1
fi

systemctl enable $FILE2 || exit 1
systemctl restart $FILE2 || exit 1
systemctl daemon-reload || exit 1
exit 0