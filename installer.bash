#!/bin/bash/env bash

# Filename:     installer.bash
# Author:       Alex Portell <https://github.com/portellam>
# Description:  Install Systemd service to toggle system wakeup (ACPI) from USB device activity.
#

# <params>
  SAVEIFS="${IFS}"
  IFS=$'\n'
  PREFIX_PROMPT="$( basename "${0}" ): "
  PREFIX_ERROR="${PREFIX_PROMPT}An error occurred: "

  DESTINATION_BIN_PATH="/usr/local/bin/"
  DESTINATION_SERVICE_PATH="/etc/systemd/system/"
  SOURCE_PATH="$( realpath "$( dirname "${0}" )" )/"
  SOURCE_BIN_FILE="acpi-sleep"
  SOURCE_SERVICE_FILE1="disable-usb-acpi-wakeup.service"
  SOURCE_SERVICE_FILE2="enabled-usb-acpi-wakeup.service"
# </params>

# <traps>
  trap 'catch' ERR
# </traps>

# <functions>
  # <params>
  OPTIONS=( "$@" )

  SCRIPT_NAME="$( basename "${0}" ): "
  PREFIX_PROMPT="${SCRIPT_NAME}: "
  PREFIX_ERROR="${PREFIX_PROMPT}An error occurred: "

  SAVEIFS="${IFS}"
  IFS=$'\n'

  DO_ENABLE_INTERFACES=false
  DO_DISABLE_INTERFACES=false
# </params>

# <traps>
  trap 'catch_error' SIGINT SIGTERM ERR
  trap 'catch_exit' EXIT
# </traps>

# <functions>
  function main
  {
    is_user_superuser && parse_options && toggle_wakeup_for_all_interfaces
    exit "${?}"
  }

  # <summary>Clean-up</summary>
    function reset_ifs
    {
      IFS="${SAVEIFS}"
    }

  # <summary>Data-type validation</summary>
    function is_string
    {
      if [[ "${1}" == "" ]]; then
        return 1
      fi
    }

  # <summary>Handlers</summary>
    function catch_error {
      exit 255
    }

    function catch_exit {
      reset_ifs
    }

    function is_user_superuser
    {
      if [[ $( whoami ) != "root" ]]; then
        print_to_log "${PREFIX_ERROR}User is not sudo or root."
        return 1
      fi
    }

    function yes_no_prompt
    {
      local output="${1}"
      is_string "${output}" && output+=" "

      for counter in $( seq 0 2 ); do
        echo -en "${output}[Y/n]: "
        read -r -p "" answer

        case "${answer}" in
          [Yy]* )
            return 0 ;;

          [Nn]* )
            return 255 ;;

          * )
            echo "Please answer 'Y' or 'N'." ;;
        esac
      done

      return 1
    }

  # <summary>Loggers</summary>
    function print_to_log
    {
      echo -e "${1}" >&2
    }

  # <summary>Options logic</summary>
    function get_option
    {
      case "${1}" in
        "-e" | "--enable" )
          DO_ENABLE_INTERFACES=true
          return 0 ;;

        "-d" | "--disable" )
          DO_DISABLE_INTERFACES=true
          return 0 ;;

        "" )
          return 0 ;;

        "-h" | "--help" | * )
          print_usage
          return 1 ;;
      esac
    }

    function parse_options
    {
      if [[ "${#OPTIONS[@]}" -eq 0 ]]; then
        prompt_option
        return "${?}"
      fi

      for option in "${OPTIONS[@]}"; do
        get_option "${option}" || return 1
      done
    }

    function print_usage
    {
      local -ar output=(
        "Usage:\tbash ${SCRIPT_NAME} [OPTION]"
        "Toggle system wakeup (ACPI) from USB device activity.\n"
        "  -h, --help    Print this help and exit."
        "  -e, --enable  Enable wakeup by USB devices at startup."
        "  -d, --disable Disable wakeup by USB devices at startup."
      )

      echo -e "${output[*]}"
    }

    function prompt_option
    {
      yes_no_prompt "Disable ACPI wakeup for USB interfaces at startup?"

      case "${?}" in
        0 )
          DO_DISABLE_INTERFACES=true ;;

        255 )
          DO_ENABLE_INTERFACES=true ;;

        1 )
          return 1
      esac

      return 0
    }

  # <summary>Business logic</summary>
    function are_source_files_missing
    {
      if ! is_file "${SOURCE_BIN_FILE}" \
        || ! is_file "${SOURCE_SERVICE_FILE1}"; then
        print_to_log "${PREFIX_ERROR}Source file(s) missing."
        return 1
      fi
    }

    function copy_sources_to_destination
    {
      if ! sudo cp "${SOURCE_PATH}${SOURCE_BIN_FILE}" "${DESTINATION_BIN_PATH}${SOURCE_BIN_FILE}" &> /dev/null \
        || ( "${DO_DISABLE_INTERFACES}" && ! sudo cp "${SOURCE_PATH}${SOURCE_SERVICE_FILE1}" "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE1}" &> /dev/null ) \
        || ( "${DO_ENABLE_INTERFACES}" && ! sudo cp "${SOURCE_PATH}${SOURCE_SERVICE_FILE2}" "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE2}" &> /dev/null ); then
        print_to_log "${PREFIX_ERROR}Failed to copy source file(s) to destination."
        return 1
      fi

      print_to_log "${PREFIX_PROMPT}Copied source file(s) to destination."
    }

    function disable_this_service_file
    {
      if ! sudo systemctl stop "${1}" &> /dev/null; then
        print_to_log "${PREFIX_ERROR}Failed to stop service file '${1}'."
        return 1
      fi

      print_to_log "${PREFIX_PROMPT}Stopped service file '${1}'."

      if ! systemctl disable "${1}" &> /dev/null; then
        print_to_log "${PREFIX_ERROR}Failed to disable service file '${1}'."
        return 1
      fi

      print_to_log "${PREFIX_PROMPT}Disabled service file '${1}'."
    }

    function is_file
    {
      if [[ ! -e "${1}" ]]; then
        print_to_log "${PREFIX_ERROR}File '${1}' not found."
        return 1
      fi
    }

    function refresh_services
    {
      if ! sudo systemctl daemon-reload; then
        print_to_log "${PREFIX_ERROR}Failed to reload Systemd."
        return 1
      fi

      print_to_log "${PREFIX_PROMPT}Reloaded Systemd."
    }

    function update_systemd
    {
      if ( "${DO_DISABLE_INTERFACES}" && ! update_this_service_file "${SOURCE_SERVICE_FILE1}" ) \
        || ( "${DO_ENABLE_INTERFACES}" && ! update_this_service_file "${SOURCE_SERVICE_FILE2}" ); then
        return 1
      fi

      if ( "${DO_DISABLE_INTERFACES}" && ! disable_this_service_file "${SOURCE_SERVICE_FILE2}" ) \
        || ( "${DO_ENABLE_INTERFACES}" && ! disable_this_service_file "${SOURCE_SERVICE_FILE1}" ); then
        return 1
      fi

      refresh_services
    }

    function update_this_service_file
    {
      if ! sudo systemctl enable "${1}" &> /dev/null; then
        print_to_log "${PREFIX_ERROR}Failed to enable service file '${1}'."
        return 1
      fi

      print_to_log "${PREFIX_PROMPT}Enabled service file '${1}'."

      if ! systemctl restart "${1}" &> /dev/null; then
        print_to_log "${PREFIX_ERROR}Failed to update service file '${1}'."
        return 1
      fi

      print_to_log "${PREFIX_PROMPT}Updated service file '${1}'."
    }