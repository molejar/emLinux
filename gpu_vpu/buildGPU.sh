#!/bin/bash

# Selection dialog
# Usage: list_dialog <title> <items>
# Return: item in RET_VALUE variable
list_dialog() {
  local title=$1; shift
  local items=$@
  local selected=0
  local cnt=0

  if [ "$param_xdialog" = "true" ]; then
    ret=$(zenity --list --title="$title" --column="$title" $items)
    if [ $? -eq 1 ]; then
      exit 0
    fi
    RET_VALUE=${ret%|*}
  else
    echo
    echo '------------------------------------------------------------'
    echo " $title "
    echo '------------------------------------------------------------'
    for item in ${items}; do 
      echo " $cnt) $item"
      cnt=$(($cnt + 1))
    done
    echo
    echo ' x) Exit'
    echo '------------------------------------------------------------'
    while [ $selected -eq 0 ] ; do
      read -p "Enter: " key
      [[ $key == 'x' ]] && exit 0
      [[ $key == ?(-)+([0-9]) ]] && [[ $key -lt $cnt ]] && selected=1
    done
    ret=($(echo ${items}))
    RET_VALUE=${ret[$key]}
    echo
  fi   
}

DESKTOP_VARIANTS=('LXDE'
               'Weston'
               'none')

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#update list of packages
apt-get update
if [ $? -ne 0 ]; then
    echo "Update of packages list failed"
    exit 1
fi

#install tools
apt-get install xinit xinput xserver-xorg-dev mesa-utils mesa-utils-extra openssh-server can-utils usbutils build-essential automake autoconf libtool git ntp libdrm-etnaviv1 -y
if [ $? -ne 0 ]; then
    echo "Installation of tools failed"
    exit 1
fi

if [ ${#DESKTOP_VARIANTS[@]} -gt 1 ]; then
        list_dialog 'Select graphical desktop variant' "${DESKTOP_VARIANTS[@]}"
        DESKTOP_VARIANT=$RET_VALUE
fi 

case $DESKTOP_VARIANT in
        'LXDE')
            #install lxde
            apt-get install lxde lxterminal lxappearance lxrandr lightdm-gtk-greeter lxshortcut lxinput -y
            if [ $? -ne 0 ]; then
                echo "Installation of lxde failed"
                exit 1
            fi

            #enable autologin
cat << EOT > /etc/lightdm/lightdm.conf
[SeatDefaults]
autologin-user=ubuntu
autologin-user-timeout=0
# Check https://bugs.launchpad.net/lightdm/+bug/854261 before setting a timeout
user-session=LXDE
greeter-session=lightdm-gtk-greeter
EOT
            ;;
         
        'Weston')
            apt-get install weston lightdm lightdm-gtk-greeter xwayland dbus-user-session dbus-x11 wayland-protocols -y
            if [ $? -ne 0 ]; then
                echo "Installation of weston failed"
                exit 1
            fi

            #enable autologin
cat << EOT > /etc/lightdm/lightdm.conf
[SeatDefaults]
autologin-user=ubuntu
autologin-user-timeout=0
# Check https://bugs.launchpad.net/lightdm/+bug/854261 before setting a timeout
user-session=weston
greeter-session=lightdm-gtk-greeter
EOT
            ;;
         
        'none')
            ;;         
        *)
            ;;
esac

#install libraries for compilation
apt-get install xutils-dev pkgconf -y
if [ $? -ne 0 ]; then
    echo "Installation of libraries needed for compilation failed"
    exit 1
fi

#download and install libdrm with etnaviv support
#wget https://dri.freedesktop.org/libdrm/libdrm-2.4.84.tar.gz
#tar -xvf libdrm-2.4.84.tar.gz
#cd libdrm-2.4.84
#./configure --enable-install-test-programs --enable-etnaviv-experimental-api --enable-libkms
#make -j4
#make install

#download and install libdrm-armada
git clone git://git.armlinux.org.uk/~rmk/libdrm-armada.git/
cd libdrm-armada
mkdir m4; autoreconf -f -i
./configure --prefix=/usr || exit 1
make || exit 1
make install
cd ..

#download and set path for etna_viv
git clone https://github.com/laanwj/etna_viv.git
ETNA_SRC=$PWD/etna_viv

#download and install xf86-vide-armada
git clone git://git.armlinux.org.uk/~rmk/xf86-video-armada.git/
cd xf86-video-armada
git checkout unstable-devel
./autogen.sh --prefix=/usr --disable-vivante --with-etnaviv-source=$ETNA_SRC || exit 1
make || exit 1
make install
cd ..

cat << EOT > /etc/X11/xorg.conf
Section "Device"
    Identifier  "Driver0"
    Screen      0
    Driver      "armada"
# Support hotplugging displays?
    Option      "Hotplug"   "TRUE"
# Support hardware cursor if available?
    Option      "HWCursor"  "TRUE"
# Use GPU acceleration?
    Option      "UseGPU"    "TRUE"
# Provide Xv interfaces?
    Option      "XvAccel"   "TRUE"
# Prefer overlay for Xv (TRUE for armada-drm, FALSE for imx-drm)
    Option      "XvPreferOverlay"   "FALSE"
# Which accelerator module to load (automatically found if commented out)
    Option      "AccelModule"   "etnadrm_gpu"
#   Option      "AccelModule" "etnaviv_gpu"
# Support DRI2 interfaces?
    Option      "DRI"   "TRUE"
EndSection
EOT
#add user ubuntu to group video
usermod -a -G video ubuntu

echo "---------------------------------------------------------------"
echo "        Congratulations, GPU instalation was successful"
echo "---------------------------------------------------------------"
