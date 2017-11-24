# Scripts for VPU and GPU

This is two after boot scripts, which can help user to enable GPU and VPU in Ubuntu on i.MX boards. 

## Script for GPU
The first one is *buildGPU.sh*, which is for GPU support and does the following:

* Update packages list
* Install tools for build and mesa
* Install desktop environment 
* Enable auto-login
* Download, compile and install Xorg driver [xf86-video-armada](http://git.arm.linux.org.uk/cgit/xf86-video-armada.git/tree/README?h=unstable-devel) 
* Copy xorg.conf file

It use open source driver [Etnaviv](https://github.com/etnaviv) for Vivante graphics, so 
you need at least version 4.8 of Linux mainline kernel .
 
You can choose from two desktop environment LXDE and Weston, or choose none and install others by your own. 
Full support of Etnaviv is in Weston 3.0, which you can find in Ubuntu 18.04. 
Etnaviv is still in development, so be sure you use the newest possible version of Ubuntu and Kernel.

## Script for VPU
The second one script is *buildVPU.sh*, which is for VPU support and does the following:

* Update packages list
* Install gstreamer
* Install mesa development libs
* Install libraries
* Download and install firmware for VPU
* Download and compile gst-plugins-good and gst-plugins-bad

The VPU support is build on open source driver CODA and V4L2 (Video for Linux 2). It need firmware for VPU, which will be downloaded and installed in
this script. Also this script have to rebuild good and bad plugins for GStreamer, so it take more time to finish.

## Usage
**Please check system time and internet connection before running this scripts**

###GPU support
You have to go to the folder where is scripts installed and run as root 
(You will be asked to choose desktop environment):
```
# ./buildGPU.sh
```

You can check GPU acceleration with command:
```
glxgears --info
```

###VPU support
For VPU support: You have to go to the folder where is scripts installed and run as root:
```
# ./buildVPU.sh
```

You can check VPU support with command:
```
gst-inspect-1.0 | grep v4l2video
```

## Usefull Links

* [Etnaviv](https://github.com/etnaviv)
* [xf86-video-armada](http://git.arm.linux.org.uk/cgit/xf86-video-armada.git/tree/README?h=unstable-devel)







