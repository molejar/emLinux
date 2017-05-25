#!/bin/bash
#################################################################################
# Author: Martin Olejar
#################################################################################

ROOT_DIR=$(dirname $(realpath $0))
. $ROOT_DIR/scripts/functions


EMLINUX_VERSION="0.1.0"

data_for_dpkg() {
  # debian/changelog file
  cat << EOF > ${1}/changelog
emlinux-tools ($EMLINUX_VERSION) unstable; urgency=medium

  * Initial release.

 -- molejar <martin.olejar@gmail.com>  Sun, 06 Mar 2016 19:24:35 +0100
EOF

  # debian/control file
  cat << EOF > ${1}/control
Source: emlinux-tools
Maintainer: Martin Olejar
Section: Utils
Priority: optional
Standards-Version: $EMLINUX_VERSION
Build-Depends:
Homepage: https://github.com/molejar/emLinux

Package: emlinux-tools
Architecture: all
Section: Utils
Priority: optional
Essential: no
Depends: build-essential, gcc-arm-linux-gnueabi, u-boot-tools, qemu-user-static, binfmt-support, debootstrap, binutils, parted, git, lzop, gzip, zip
Description: Automatization tools for embedded Linux development.
  This package include a collection of useful commands for compiling toolchain, u-boot, kernel, rootfs and generating bootable image.
  More details you can found here: https://github.com/molejar/emLinux
EOF

  # debian/copyright file
  cat << EOF > ${1}/copyright
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Source: https://github.com/molejar/emLinux

Files: *
Copyright: 2017, Martin Olejar
License: Expat

License: Expat
 The MIT License
 .
 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 .
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 .
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
EOF

  # debian/rules file
  cat << EOF > ${1}/rules
#!/usr/bin/make -f
# -*- makefile -*-
# Sample debian/rules that uses debhelper.
# This file was originally written by Joey Hess and Craig Small.
# As a special exception, when this file is copied by dh-make into a
# dh-make output file, you may use that output file without restriction.
# This special exception was added by Craig Small in version 0.37 of dh-make.

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

%:
	dh \$@
EOF

  chmod a+x ${1}/rules

  # debian/compat file
  echo "9" > ${1}/compat

  # debian/install file
  echo "scripts/* /sbin" > ${1}/install

  # debian/source/format file
  echo "3.0 (native)" > ${1}/source/format
}

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

  [[ -d $ROOT_DIR/release ]] || mkdir $ROOT_DIR/release
  TMP_DIR=$(mktemp -d)

  mkdir -p $TMP_DIR/emlinux-tools-${EMLINUX_VERSION}/debian/source
  data_for_dpkg "$TMP_DIR/emlinux-tools-${EMLINUX_VERSION}/debian"
  cp -Rf $ROOT_DIR/scripts $TMP_DIR/emlinux-tools-${EMLINUX_VERSION}
  cd $TMP_DIR/emlinux-tools-${EMLINUX_VERSION}
  chmod a+x scripts/build*

  export LC_ALL=C
  dpkg-buildpackage -uc -us
  cp $TMP_DIR/*.deb $ROOT_DIR/release
  cd $ROOT_DIR/release
  rm -rf $TMPDIR

  mkdir emlinux-vm_${EMLINUX_VERSION}
  cp $ROOT_DIR/Vagrantfile emlinux-vm_${EMLINUX_VERSION}
  cp $ROOT_DIR/*.conf emlinux-vm_${EMLINUX_VERSION}
  zip -r emlinux-vm_${EMLINUX_VERSION}.zip emlinux-vm_${EMLINUX_VERSION}
  rm -rf emlinux-vm_${EMLINUX_VERSION}
  cd $CWD

  echo
  echo " Output: $ROOT_DIR/release"
  echo
else
  PACKAGES=$(ls $ROOT_DIR/scripts | grep "build")
  cd /sbin

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
