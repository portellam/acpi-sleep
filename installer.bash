#!/bin/bash/env bash

# Filename:     installer.bash
# Author:       Alex Portell <https://github.com/portellam>
# Description:  Install Systemd service to toggle system wakeup (ACPI) from USB device activity.
#

# <traps>
  trap 'catch_error' SIGINT SIGTERM ERR
  trap 'catch_exit' EXIT
# </traps>

# <params>
  OPTIONS=( "$@" )

  SCRIPT_NAME="$( basename "${0}" )"
  PREFIX_PROMPT="${SCRIPT_NAME}: "
  PREFIX_ERROR="${PREFIX_PROMPT}An error occurred: "

  SAVEIFS="${IFS}"
  IFS=$'\n'

  DO_DISABLE_INTERFACES=false
  DO_ENABLE_INTERFACES=false
  DO_UNINSTALL=false

  DESTINATION_BIN_PATH="/usr/local/bin/"
  DESTINATION_SERVICE_PATH="/etc/systemd/system/"
  SOURCE_PATH="$( realpath "$( dirname "${0}" )" )/"
  SOURCE_BIN_FILE="acpi-sleep"
  SOURCE_SERVICE_FILE1="acpi-sleep-allow-usb-wakeup.service"
  SOURCE_SERVICE_FILE2="acpi-sleep-deny-usb-wakeup.service"
# </params>

# <functions>
  function main
  {
    if ! is_user_superuser \
      || ! parse_options \
      || ! execute_install \
      || ! execute_uninstall; then
      false
    fi

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

        "--uninstall" )
          DO_UNINSTALL=true ;;

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
        prompt_options
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
        "  -d, --disable Disable wakeup by USB devices at startup."
        "  -e, --enable  Enable wakeup by USB devices at startup."
        "  --uninstall   Uninstall all source files from system, and remove related startup services."
        "  -h, --help    Print this help and exit."
      )

      echo -e "${output[*]}"
    }

    function prompt_options
    {
      if ! "${DO_UNINSTALL}"; then
        yes_no_prompt "Install?"
      fi

      case "${?}" in
        255 )
          DO_UNINSTALL=true ;;

        1 )
          return 1
      esac

      if ! "${DO_UNINSTALL}"; then
        yes_no_prompt "Disable ACPI wakeup for USB interfaces at startup?"
      fi

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
    # <summary>Install</summary>
      function execute_install
      {
        if "${DO_UNINSTALL}"; then
          return 1
        fi

        if ! copy_sources_to_destination \
          || ! update_services_for_install; then
          print_to_log "${PREFIX_ERROR}Install failed."
          exit 1
        fi
      }

      function are_source_files_missing
      {
        if ! is_file "${SOURCE_PATH}${SOURCE_BIN_FILE}" \
          || ! is_file "${SOURCE_PATH}${SOURCE_SERVICE_FILE1}"; then
          print_to_log "${PREFIX_ERROR}Source file(s) missing."
          return 1
        fi
      }

      function copy_sources_to_destination
      {
        are_source_files_missing || return 1

        if ! sudo cp --force "${SOURCE_PATH}${SOURCE_BIN_FILE}" "${DESTINATION_BIN_PATH}${SOURCE_BIN_FILE}" &> /dev/null \
          || ( "${DO_DISABLE_INTERFACES}" && ! sudo cp --force "${SOURCE_PATH}${SOURCE_SERVICE_FILE1}" "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE1}" &> /dev/null ) \
          || ( "${DO_ENABLE_INTERFACES}" && ! sudo cp --force "${SOURCE_PATH}${SOURCE_SERVICE_FILE2}" "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE2}" &> /dev/null ); then
          print_to_log "${PREFIX_ERROR}Failed to copy source file(s) to destination."
          return 1
        fi

        print_to_log "${PREFIX_PROMPT}Copied source file(s) to destination."
      }

      function update_services_for_install
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

    # <summary>Shared logic</summary>
      function disable_this_service_file
      {
        if ! sudo systemctl disable "${1}" &> /dev/null; then
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

      function update_this_service_file
      {
        if ! sudo systemctl enable "${1}" &> /dev/null; then
          print_to_log "${PREFIX_ERROR}Failed to enable service file '${1}'."
          return 1
        fi

        print_to_log "${PREFIX_PROMPT}Enabled service file '${1}'."

        if ! sudo systemctl restart "${1}" &> /dev/null; then
          print_to_log "${PREFIX_ERROR}Failed to update service file '${1}'."
          return 1
        fi

        print_to_log "${PREFIX_PROMPT}Updated service file '${1}'."
    }

     # <summary>Uninstall<summary>
      function execute_uninstall
      {
        if ! "${DO_UNINSTALL}"; then
          return 1
        fi

        if ! remove_destination_files \
          || ! update_services_for_uninstall; then
          print_to_log "${PREFIX_ERROR}Uninstall failed."
          exit 1
        fi
      }

      function remove_destination_files
      {
        if ( is_file "${DESTINATION_BIN_PATH}${SOURCE_BIN_FILE}" &> /dev/null && ! sudo rm --force "${DESTINATION_BIN_PATH}${SOURCE_BIN_FILE}" &> /dev/null ) \
          || ( is_file "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE1}" &> /dev/null && ! sudo rm --force "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE1}" &> /dev/null ) \
          || ( is_file "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE2}" &> /dev/null && ! sudo rm --force "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE2}" &> /dev/null ); then
          print_to_log "${PREFIX_ERROR}Failed to delete destination file(s)."
          return 1
        fi
      }

      function update_services_for_uninstall
      {
        if ! disable_this_service_file "${SOURCE_SERVICE_FILE2}"\
          || ! disable_this_service_file "${SOURCE_SERVICE_FILE1}"; then
          return 1
        fi

        refresh_services
      }

# <code>
  main
# </code>