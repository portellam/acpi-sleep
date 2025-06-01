#!/bin/bash/env bash

# Filename:     get-lspci-from-enabled-acpi.sh
# Author:       Alex Portell <https://github.com/portellam>
# Description:  WIP
# Version:      1.0.0
#

#region main

array=(
  $( \
    cat /proc/acpi/wakeup \
      | grep enabled \
      | awk '{print $4}' \
      | sed 's/pci:0000://g' \
  )
)

max_count=$(( ${#array[@]} - 1 ))

for index in "${!array[@]}"; do
  line="${array[${index}]}"

  echo ${index}:

  cat /proc/acpi/wakeup \
    | grep "${line}" \
    | grep enabled

  lspci -s "${line}"

  if [[ "${index}" -ge "${max_count}" ]]; then
    break
  fi

  echo
done

#endregion