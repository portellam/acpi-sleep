#!/bin/bash

# Filename:     better-lsusb
# Author:       Alex Portell <https://github.com/portellam>
# Description:  WIP
# Version:      1.0.0
#


# exit 1

path="/proc/acpi/wakeup"
echo -e "Status\t\tDescription"

while IFS= read -r line; do
  device_id=$( \
    echo "${line}" \
      | awk '{print $6}'
  )

  if grep -q "${device_id}" "${path}"; then
    state="*enabled"
  else
    state="*disabled"
  fi

  echo -e "$state\t$line"
done < <( lsusb ) \
  | sort \
    --key 1,1 \
    --key 2,2