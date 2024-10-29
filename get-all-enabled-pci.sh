#!/bin/bash

# get all PCI devices which wakeup the PC.

echo "List of PCI devices which can wake the system:"

path="/proc/acpi/wakeup"
state="enabled"

for index in $( \
  seq \
    1 \
    $( \
      cat \
        "${path}" \
      | grep \
        "${state}" \
      | wc \
        --lines \
    )
); do
  line="$( \
    cat \
      "${path}" \
    | grep \
      "${state}" \
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
    "\t${name}\t"

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
done \
| sort \
  --version-sort

# get all USB devices which wakeup the PC.
echo
echo "List of USB devices which can wake the system:"

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

for id in ${id_list[@]}; do
  bus="$( \
    echo \
      "${id}" \
    | cut \
      --delimiter \
        "-" \
      --fields \
        1
  )"

  device="$( \
    echo \
      "${id}" \
    | cut \
      --delimiter \
        "-" \
      --fields \
        2 \
    | cut \
      --delimiter \
        "." \
      --fields \
        1
  )"

  output="$( \
    lsusb \
      -s \
        "${bus}:${device}"
  )"

  if [[ "${output}" == "" ]]; then
    continue
  fi

  echo \
    -e \
    -n \
    "\t${output}\n"
done \
| sort \
  --version-sort