#!/bin/bash
#################################################################################
# Author: Martin Olejar
#################################################################################

sudo apt-get install build-essential fakeroot devscripts build-dep fdupes

dpkg-buildpackage -uc -us

