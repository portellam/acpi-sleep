#!/bin/bash

# Filename:     new.sh
# Author:       Alex Portell <https://github.com/portellam>
# Description:  WIP
# Version:      1.0.0
#

path="/proc/acpi/wakeup"

echo -e \
  "$( \
    cat "${path}" \
      | head --lines 1
  )\t\tDescription"

for line in \
  "$( \
    cat "${path}" \
      | tail -n +2 \
      | grep "pci:" \
  )"; do

  pci="$( \
    echo "${line}" \
      | awk 'END {print $4}' \
      | sed \
        --expression "s/^pci://"
  )"

  description=$( \
    lspci \
      -s "${pci}"
  )

  if [[ "${description}// " == "" ]]; then
    description="N/A"
  fi

  echo -e -n "${line}\t${description}"
done

echo