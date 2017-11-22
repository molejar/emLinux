#!/bin/bash


if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#update package list
apt-get update
if [ $? -ne 0 ]; then
    echo "Update of packages list failed"
    exit 1
fi

#install gstreamer
apt-get install gstreamer1.0-x gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-alsa libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-libav -y
if [ $? -ne 0 ]; then
    echo "Installation of gstreamer failed"
    exit 1
fi

#install mesa
apt-get install mesa-common-dev libegl1-mesa-dev libgl1-mesa-dev libgles2-mesa-dev libglu1-mesa-dev libglw1-mesa-dev -y
if [ $? -ne 0 ]; then
    echo "Installation of mesa-dev failed"
    exit 1
fi

#install libraries
apt-get install libbison-dev liborc-0.4-0 liborc-0.4-dev-bin liborc-0.4-dev flex gtk-doc-tools pulseaudio -y
 if [ $? -ne 0 ]; then
    echo "Installation of libraries failed"
    exit 1
fi

#detect version of GStreamer
VERSION_COMMAND=`gst-launch-1.0 --version | grep GStreamer | sed "s/^.*GStreamer \([0-9.]\)/\1/"`
if [ -z "$VERSION_COMMAND" ]; then
    echo "Can't detect gstreamer version"
    exit 1
fi
VERSION_ARRAY=( ${VERSION_COMMAND//./ } )
VERSION_MM="${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}"
echo $VERSION_MM

# install firmware for VPU
mkdir vpu 
cd vpu
wget http://www.freescale.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-5.4.bin
chmod +x firmware-imx-5.4.bin
firmware-imx-5.4.bin --auto-accept
mkdir -p /lib/firmware/vpu
cp firmware-imx-*/firmware/vpu/vpu_fw_imx6*.bin /lib/firmware/vpu

#compile and install plugins good
git clone -b $VERSION_MM git://anongit.freedesktop.org/gstreamer/gst-plugins-good
cd gst-plugins-good
./autogen.sh  --enable-orc --enable-v4l2-probe --with-libv4l2 --enable-experimental --libdir=/usr/lib/arm-linux-gnueabihf || exit 1
make || exit 1
make install
cd ..

#compile and install plugins bad
git clone -b $VERSION_MM git://anongit.freedesktop.org/gstreamer/gst-plugins-bad
cd gst-plugins-bad
./autogen.sh  --enable-orc --enable-kms --enable-experimental --libdir=/usr/lib/arm-linux-gnueabihf || exit 1
make || exit 1
make install
cd ..

echo "---------------------------------------------------------------"
echo "        Congratulations, VPU instalation was successful"
echo "---------------------------------------------------------------"
