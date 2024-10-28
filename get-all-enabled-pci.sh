#!/bin/bash

# get all PCI devices which wakeup the PC.

for index in $( \
  seq \
    1 \
    $( \
      cat \
        /proc/acpi/wakeup \
      | grep \
        enabled \
      | wc \
        --lines \
    )
); do
  line="$( \
    cat \
      /proc/acpi/wakeup \
    | grep \
      enabled \
    | sed \
      --quiet \
      "${index}p"
  )"

  name="$( \
    echo \
      "${line}" \
    | awk \
      'END {print $1}'
  )"

  echo \
    -e \
    -n \
    "${name}\t"

  lspci \
    -s \
      $( \
        echo \
          "${line}" \
        | awk \
          'END {print $4}' \
        | sed \
          --expression \
            "s/^pci://"
      )
done

prefix="/sys/bus/usb/devices/"
suffix="/power/wakeup"
path="${prefix}*${suffix}"
prefix="${prefix//\//\\/}"
suffix="${suffix//\//\\/}"
state="enabled"
state_suffix=":${state}"

for line in $( \
  grep \
    . \
    ${path} \
  | grep \
    "${state}"
); do
  path="$( \
    echo \
      "${line}" \
    | sed \
      --expression \
        "s/${state_suffix}$//"
  )"

  bus="$( \
    echo \
      "${line}" \
    | sed \
      --expression \
        "s/^${prefix}//" \
      --expression \
        "s/${suffix}${state_suffix}$//"
  )"

  echo \
  "${bus}"
done