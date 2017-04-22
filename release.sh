#!/bin/bash
#################################################################################
# Author: Martin Olejar
#################################################################################

sudo apt-get install build-essential fakeroot devscripts debhelper fdupes

ROOTDIR=$(dirname $(realpath $0))

[ -d $ROOTDIR/release/tmp ] && rm -rf $ROOTDIR/release/tmp
mkdir -p $ROOTDIR/release/tmp/pkg

cp -Rf $ROOTDIR/debian $ROOTDIR/release/tmp/pkg
cp -Rf $ROOTDIR/scripts $ROOTDIR/release/tmp/pkg
cd $ROOTDIR/release/tmp/pkg

dpkg-buildpackage -uc -us

cp $ROOTDIR/release/tmp/*.deb $ROOTDIR/release
rm -rf $ROOTDIR/release/tmp

cd $ROOTDIR