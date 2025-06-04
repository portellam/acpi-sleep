#!/bin/bash/env bash

# Filename:       installer.bash
# Description:    Installs ACPI Sleep.
# Author(s):      Alex Portell <github.com/portellam>
# Maintainer(s):  Alex Portell <github.com/portellam>
# Version:        1.1.0
#

#region Traps

trap 'catch_error' SIGINT SIGTERM ERR
trap 'catch_exit' EXIT

#endregion

#region Parameters

OPTIONS=( "$@" )

declare -r SCRIPT_VERSION="1.0.0"
declare -r SCRIPT_NAME="$( basename "${0}" )"
declare -r PREFIX_PROMPT="${SCRIPT_NAME}: "
declare -r PREFIX_ERROR="An error occurred:${RESET_COLOR} "

SAVEIFS="${IFS}"
IFS=$'\n'

DO_DISABLE_INTERFACES=false
DO_ENABLE_INTERFACES=false
DO_INSTALL=false
DO_UNINSTALL=false

DESTINATION_BIN_PATH="/usr/local/bin/"
DESTINATION_SERVICE_PATH="/etc/systemd/system/"
SOURCE_PATH="$( realpath "$( dirname "${0}" )" )/"
SOURCE_BIN_FILE="acpi-sleep"
SOURCE_SERVICE_FILE1="acpi-sleep-allow-usb-wakeup.service"
SOURCE_SERVICE_FILE2="acpi-sleep-deny-usb-wakeup.service"

#endregion

#region Logic

function main
{
  if ! is_user_superuser \
    || ! parse_options \
    || ! prompt_options; then
    exit 1
  fi

  case true in
    "${DO_INSTALL}" )
      execute_install ;;

    "${DO_UNINSTALL}" )
      execute_uninstall ;;
  esac

  exit "${?}"
}

  #region Clean-up

  function reset_ifs
  {
    IFS="${SAVEIFS}"
  }

  #endregion

  #region Data-type validation

  function is_string
  {
    if [[ "${1}" == "" ]]; then
      return 1
    fi
  }

  #endregion

  #region Handlers

  function catch_error {
    exit 255
  }

  function catch_exit {
    reset_ifs
  }

  function is_user_superuser
  {
    if [[ $( whoami ) != "root" ]]; then
      print_to_error_log "User is not sudo or root."
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

  #endregion

  #region Loggers

  function print_to_error_log
  {
    echo -e "${PREFIX_ERROR}${1}" >&2
  }

  function print_to_output_log
  {
    echo -e "${PREFIX_PROMPT}${1}" >&1
  }

  #endregion

  #region Options logic

  function get_option
  {
    case "${1}" in
      "-e" | "--enable" )
        DO_ENABLE_INTERFACES=true
        DO_INSTALL=true
        return 0 ;;

      "-d" | "--disable" )
        DO_DISABLE_INTERFACES=true
        DO_INSTALL=true
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
    for option in "${OPTIONS[@]}"; do
      get_option "${option}" || return 1
    done
  }

  function print_usage
  {
    local -ar output=(
      "Usage:\tbash ${SCRIPT_NAME} [OPTION]"
      "Toggle wakeup by ACPI of a Linux machine from USB device activity."
      "Version ${SCRIPT_VERSION}.\n"
      "  -d, --disable Disable wakeup by USB devices at startup."
      "  -e, --enable  Enable wakeup by USB devices at startup."
      "  --uninstall   Uninstall all source files from system, and remove related startup services."
      "  -h, --help    Print this help and exit."
    )

    echo -e "${output[*]}"
  }

  #endregion

  #region Prompt logic

  function prompt_options
  {
    if ! prompt_install \
      || ! prompt_disable; then
      return 1
    fi
  }

  function prompt_disable
  {
    if "${DO_UNINSTALL}" \
      || ( "${DO_INSTALL}" \
        && ( "${DO_DISABLE_INTERFACES}" || "${DO_ENABLE_INTERFACES}" ) ); then
      return 0
    fi

    yes_no_prompt "Disable ACPI wakeup for USB interfaces at startup?"

    case "${?}" in
      0 )
        DO_DISABLE_INTERFACES=true ;;

      1 )
        exit 1 ;;

      255 )
        DO_ENABLE_INTERFACES=true ;;
    esac

    return 0
  }

  function prompt_install
  {
    if "${DO_INSTALL}" \
      || "${DO_UNINSTALL}" \
      || "${DO_DISABLE_INTERFACES}" \
      || "${DO_ENABLE_INTERFACES}"; then
      return 0
    fi

    yes_no_prompt "Install?"

    case "${?}" in
      0 )
        DO_INSTALL=true ;;

      1 )
        exit 1 ;;

      255 )
        DO_UNINSTALL=true ;;
    esac

    return 0
  }

  #endregion

  #region Business logic

    #region Install

    function execute_install
    {
      if ( ! "${DO_DISABLE_INTERFACES}" && ! "${DO_ENABLE_INTERFACES}" ) \
        || ! copy_sources_to_destination \
        || ! update_services_for_install; then
        print_to_error_log "Install failed."
        exit 1
      fi

      print_to_output_log "Install successful."
    }

    function are_source_files_missing
    {
      if ! is_file "${SOURCE_PATH}${SOURCE_BIN_FILE}" \
        || ! is_file "${SOURCE_PATH}${SOURCE_SERVICE_FILE1}"; then
        print_to_error_log "Source file(s) missing."
        return 1
      fi
    }

    function copy_sources_to_destination
    {
      are_source_files_missing || return 1

      if ! sudo cp --force "${SOURCE_PATH}${SOURCE_BIN_FILE}" "${DESTINATION_BIN_PATH}${SOURCE_BIN_FILE}" &> /dev/null \
        || ( "${DO_DISABLE_INTERFACES}" && ! sudo cp --force "${SOURCE_PATH}${SOURCE_SERVICE_FILE1}" "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE1}" &> /dev/null ) \
        || ( "${DO_ENABLE_INTERFACES}" && ! sudo cp --force "${SOURCE_PATH}${SOURCE_SERVICE_FILE2}" "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE2}" &> /dev/null ); then
        print_to_error_log "Failed to copy source file(s) to destination."
        return 1
      fi

      print_to_output_log "Copied source file(s) to destination."
    }

    function update_services_for_install
    {
      if ( "${DO_DISABLE_INTERFACES}" \
          && ( ! enable_this_service "${SOURCE_SERVICE_FILE1}" || ! start_this_service "${SOURCE_SERVICE_FILE1}" ) ) \
        || ( "${DO_ENABLE_INTERFACES}" \
          && ( ! enable_this_service "${SOURCE_SERVICE_FILE2}" || ! start_this_service "${SOURCE_SERVICE_FILE2}" ) ); then
        return 1
      fi

      if ( "${DO_ENABLE_INTERFACES}" && ! terminate_this_service "${SOURCE_SERVICE_FILE1}" ) \
        || ( "${DO_DISABLE_INTERFACES}" && ! terminate_this_service "${SOURCE_SERVICE_FILE2}" ); then
        return 1
      fi

      refresh_services
    }

    #endregion

    #region Shared logic

    function disable_this_service
    {
      if ! sudo systemctl disable "${1}" &> /dev/null; then
        print_to_error_log "Failed to disable '${1}'."
        return 1
      fi

      print_to_output_log "Disabled service '${1}'."
    }

    function enable_this_service
    {
      if ! sudo systemctl enable "${1}" &> /dev/null; then
        print_to_error_log "Failed to enable '${1}'."
        return 1
      fi

      print_to_output_log "Enabled '${1}'."
    }

    function is_file
    {
      if [[ ! -e "${1}" ]]; then
        print_to_error_log "File '${1}' not found."
        return 1
      fi
    }

    function refresh_services
    {
      if ! sudo systemctl daemon-reload; then
        print_to_error_log "Failed to reload services."
        return 1
      fi

      print_to_output_log "Reloaded services."
    }

    function start_this_service
    {
      if ! sudo systemctl start "${1}" &> /dev/null; then
        print_to_error_log "Failed to start '${1}'."
        return 1
      fi

      print_to_output_log "Started service '${1}'."
    }

    function stop_this_service
    {
      if ! sudo systemctl stop "${1}" &> /dev/null; then
        print_to_error_log "Failed to stop '${1}'."
        return 1
      fi

      print_to_output_log "Stopped service '${1}'."
    }

    function terminate_this_service
    {
      if is_file "${DESTINATION_SERVICE_PATH}${1}" &> /dev/null \
          && ( ! stop_this_service "${1}" || ! disable_this_service "${1}" ); then
        return 1
      fi
    }

    #endregion

    #region Uninstall

    function execute_uninstall
    {
      if ! remove_destination_files \
        || ! update_services_for_uninstall; then
        print_to_error_log "Uninstall failed."
        exit 1
      fi

      print_to_output_log "Uninstall successful."
    }

    function remove_destination_files
    {
      if ( is_file "${DESTINATION_BIN_PATH}${SOURCE_BIN_FILE}" &> /dev/null && ! sudo rm --force "${DESTINATION_BIN_PATH}${SOURCE_BIN_FILE}" &> /dev/null ) \
        || ( is_file "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE1}" &> /dev/null && ! sudo rm --force "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE1}" &> /dev/null ) \
        || ( is_file "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE2}" &> /dev/null && ! sudo rm --force "${DESTINATION_SERVICE_PATH}${SOURCE_SERVICE_FILE2}" &> /dev/null ); then
        print_to_error_log "Failed to delete destination file(s)."
        return 1
      fi

      print_to_output_log "Deleted destination file(s)."
    }

    function update_services_for_uninstall
    {
      if ! terminate_this_service "${SOURCE_SERVICE_FILE1}" \
        || ! terminate_this_service "${SOURCE_SERVICE_FILE2}"; then
        return 1
      fi

      refresh_services
    }

    #endregion

  #endregion

#endregion

#region Main

main "${@}"

#endregion