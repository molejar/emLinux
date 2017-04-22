#!/bin/bash
#################################################################################
# Author: Martin Olejar
#################################################################################

sudo apt-get install build-essential fakeroot devscripts debhelper fdupes

dpkg-buildpackage -uc -us

