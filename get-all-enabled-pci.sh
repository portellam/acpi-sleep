#!/bin/bash

function get_pci_devices
{
  path="/proc/acpi/wakeup"
  index_count="$( \
    cat \
      "${path}" \
    | grep \
      "${state}" \
    | wc \
      --lines
  )"

  for index in $( \
    seq \
      1 \
      "${index_count}"
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

    pci="$( \
      echo \
        "${line}" \
      | awk \
        'END {print $4}'
    )"

    if [[ "${pci}" == "" ]]; then
      continue
    fi

    echo \
      -e \
      -n \
      "\t${name}\t"

    lspci \
      -s \
        $( \
          echo \
            "${pci}" \
          | sed \
            --expression \
              "s/^pci://"
        )
  done \
  | sort \
    --version-sort

  if [[ "${index_count}" -eq 0 ]]; then
    echo \
      -e \
      "${message}"
  fi
}

function get_usb_devices
{
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

  if [[ "${#id_list[@]}" -eq 0 ]]; then
    echo \
      -e \
      "${message}"
  fi
}

state="enabled"
message="\tNo devices found."

echo \
  -e \
  "\nList of PCI devices which can wake the system:"

get_pci_devices

echo \
  -e \
  "\nList of USB devices which can wake the system:"

get_usb_devices

state="disabled"

echo \
  -e \
  "\nList of PCI devices which cannot wake the system:"

get_pci_devices

echo \
  -e \
  "\nList of USB devices which cannot wake the system:"

get_usb_devices