#!/bin/bash
#################################################################################
# Author: Martin Olejar
#################################################################################

ROOT_DIR=$(dirname $(realpath $0))
. $ROOT_DIR/scripts/functions

usage() {
cat << EOF
Usage: $0 [options]

emlinux installer for i.MX (NXP MPU)

OPTIONS:
   -h/--help   Show this message
   -u          Uninstall
   -q          Quiet, no output messages

EOF
}

# Get the params from arguments provided
argparse "?|h|help u|uninstall q|quiet" $*
if [ $? -eq 0 ]; then
  echo
  echo "Use: $0 -h/--help for usage description"
  exit 1
fi

# process help argument and exit
[[ "$param_help" = "true" ]] && {
  usage
  exit 0
}

# Make sure only root can run this script
if [ "$(id -u)" != "0" ]; then
   eprint "This script must be run as root"
   exit 1
fi

[[ "$param_quiet" != "true" ]] && {
  echo
  echo '***********************************************************'
  echo '*              Embedded Linux Tools Installer             *'
  echo '***********************************************************'
  echo
  echo " For printing all usable options use \"install -h\""
  echo
}

CWD=$(pwd)
BIN_PATH="/usr/bin"

PACKAGES=$(ls ${ROOT_DIR}/scripts | grep "build")

cd $BIN_PATH

if [ -z $param_uninstall ]; then
  for PKG in $PACKAGES; do
    if [ -z "$(which $PKG)" ]; then
      [[ "$param_quiet" != "true" ]] && echo " Install: $PKG"
      [[ -x ${ROOT_DIR}/scripts/${PKG} ]] || chmod a+x ${ROOT_DIR}/scripts/${PKG}
      ln -f -s ${ROOT_DIR}/scripts/${PKG} ${PKG}
    fi
  done
else
  for PKG in $PACKAGES; do
    if [ -e $PKG ]; then
      [[ "$param_quiet" != "true" ]] && echo " Uninstall: $PKG"
      rm -f ${PKG}
    fi
  done
fi

[[ "$param_quiet" != "true" ]] && {
  echo
  echo " DONE"
  echo
}

cd $CWD
