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
   -r          Release
   -q          Quiet, no output messages

EOF
}

# Get the params from arguments provided
argparse "?|h|help u|uninstall r|release q|quiet" $*
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

if [ "$param_release" = "true"  ]; then
  # Check if installed required packages and install if doesn't
  check_package "build-essential"
  check_package "fakeroot"
  check_package "devscripts"
  check_package "debhelper"
  check_package "fdupes"
  check_package "dh-make"

  echo " Building Debian package, please wait"
  echo

  [ -d $ROOT_DIR/release/tmp ] && rm -rf $ROOT_DIR/release/tmp
  mkdir -p $ROOT_DIR/release/tmp/pkg

  cp -Rf $ROOT_DIR/debian $ROOT_DIR/release/tmp/pkg
  cp -Rf $ROOT_DIR/scripts $ROOT_DIR/release/tmp/pkg
  cd $ROOT_DIR/release/tmp/pkg

  dpkg-buildpackage -uc -us
  cp $ROOT_DIR/release/tmp/*.deb $ROOT_DIR/release

  cd $CWD
  rm -rf $ROOT_DIR/release/tmp

  echo
  echo " Output: $ROOT_DIR/release/$(ls $ROOT_DIR/release)"
  echo
else
  PACKAGES=$(ls $ROOT_DIR/scripts | grep "build")
  cd /usr/bin

  if [ -z $param_uninstall ]; then
    for PKG in $PACKAGES; do
      if [ -z "$(which $PKG)" ]; then
        [[ "$param_quiet" != "true" ]] && echo " Install: $PKG"
        [[ -x $ROOT_DIR/scripts/$PKG ]] || sudo chmod a+x $ROOT_DIR/scripts/$PKG
        sudo ln -f -s $ROOT_DIR/scripts/$PKG $PKG
      fi
    done
  else
    for PKG in $PACKAGES; do
      if [ -e $PKG ]; then
        [[ "$param_quiet" != "true" ]] && echo " Uninstall: $PKG"
        sudo rm -f $PKG
      fi
    done
  fi

  cd $CWD

  [[ "$param_quiet" != "true" ]] && {
    echo
    echo " DONE"
    echo
  }
fi
