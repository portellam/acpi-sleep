#!/bin/bash

# Filename:     better-lsusb
# Author:       Alex Portell <https://github.com/portellam>
# Description:  WIP
# Version:      1.0.0
#


exit 1

path="/proc/acpi/wakeup"
echo -e "Status\t\tDescription"

prefix="/sys/bus/usb/devices/"
  suffix="/power/wakeup"
  path="${prefix}*${suffix}"
  prefix="${prefix//\//\\/}"
  suffix="${suffix//\//\\/}"
  state_suffix=":${state}"

  id_list=()

  for line_list in $( \
    grep \
      . \
      ${path} \
    | grep \
      "${state}"
  ); do
    for line in "${line_list[@]}"; do
      path="$( \
        echo \
          "${line}" \
        | sed \
          --expression \
            "s/${state_suffix}$//"
      )"

      id="$( \
        echo \
          "${line}" \
        | sed \
          --expression \
            "s/^${prefix}//" \
          --expression \
            "s/${suffix}${state_suffix}$//"
      )"

      id_list+=( "${id}" )
    done
  done


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

