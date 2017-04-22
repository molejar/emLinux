#!/bin/bash
#################################################################################
# Author: Martin Olejar
#################################################################################

. scripts/functions

usage() {
cat << EOF
Usage: $0 [options]

emlinux installer for i.MX (NXP MPU)

OPTIONS:
   -h/--help   Show this message
   -u          Uninstall
   -x          Use XDialog
   -v          Verbose

EOF
}

# Get the params from arguments provided
argparse "?|h|help u|uninstall x|xdialog v|verbose" $*
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

echo
echo '***********************************************************'
echo '*              Embedded Linux Tools Installer             *'
echo '***********************************************************'
echo
echo " For printing all usable options use \"install -h\""
echo

CWD="$(pwd)"
BIN_PATH="/usr/bin"

PACKAGES=$(ls ${CWD}/scripts | grep "build")

cd $BIN_PATH

if [ -z $param_uninstall ]; then
  for PKG in $PACKAGES; do
    if [ -z "$(which $PKG)" ]; then
      echo " Install: $PKG"
      [[ -x ${CWD}/scripts/${PKG} ]] || chmod a+x ${CWD}/scripts/${PKG}
      ln -f -s ${CWD}/scripts/${PKG} ${PKG}
    fi
  done
else
  for PKG in $PACKAGES; do
    if [ -e $PKG ]; then
      echo " Uninstall: $PKG"
      rm -f ${PKG}
    fi
  done
fi

cd $CWD

echo
echo " DONE"
echo

