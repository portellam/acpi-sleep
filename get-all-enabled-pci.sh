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
  lspci \
    -s \
      $( \
        cat \
          /proc/acpi/wakeup \
        | grep \
          enabled \
        | sed \
          --quiet \
          "${index}p" \
        | awk \
          'END {print $4}' \
        | sed \
          --expression
            "s/^pci://"
      )
done
