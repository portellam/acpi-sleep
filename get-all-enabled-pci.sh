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
