#!/bin/bash
#
# Author:       Alex Portell <https://github.com/portellam>
# Description:  Disable ACPI wakeup on USB interfaces' activity.
#

SAVEIFS=$IFS
IFS=$'\n'
for LINE in $( cat /proc/acpi/wakeup | grep -i 'enabled' | grep -Ei '*EHC*|*XHC*' | cut -d ' ' -f1 ); do
    echo $LINE > /proc/acpi/wakeup || exit 1
done
IFS=$SAVEIFS
exit 0
