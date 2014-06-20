#!/bin/sh
#
# Gestion des messages dans le shell
#
. /etc/init.d/functions

log_message() {
  ACTION=$1
  shift
  
  case "$ACTION" in
    success)
          echo -n $*
          success "$*"
          echo
          ;;
    failure)
          echo -n $*
          failure "$*"
          echo
          ;;
    warning)
          echo -n $*
          warning "$*"
          echo
          ;;
    *)
          ;;
  esac
}

log_success_msg () {
  log_message success "$@"
}

log_failure_msg () {
  log_message failure "$@"
}

log_warning_msg () {
  log_message warning "$@"
}
