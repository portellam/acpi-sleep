#!/bin/bash

# Filename:     new.sh
# Author:       Alex Portell <https://github.com/portellam>
# Description:  WIP
# Version:      1.0.0
#

path="/proc/acpi/wakeup"

echo -e \
  "$( head --lines 1 "${path}" )\t\tDescription"

mapfile -t lines < <\
( \
  grep "pci:" "${path}" \
    | tail -n +2 \
)

for line in "${lines[@]}"; do
  pci="$( \
    echo "${line}" \
      | awk '{print $4}' \
      | sed 's/^pci://' \
  )"

  description=$( \
    lspci \
      -s "${pci}"\
  )

  if [[ -z "${description// }" ]]; then
    description="N/A"
  fi

  echo -e "${line}\t${description}"
done