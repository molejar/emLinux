# Enablement for Embedded Linux Development

This repository contain a set of automazitation scripts for:

* generating virtual machine with Linux OS (debian or ubuntu)
* compiling `toolchain`, `u-boot` and `kernel`
* building `rootfs` for different Linux distributions like `debian`, `ubuntu`, ...
* creating or extracting bootable `SD Card` image
* building `yocto` images with intuitive wizard

## Motivation

Make Embedded Linux Development happy !

## Installation

For installing the collection of automazitation scripts into your PC run the following commands in shell window:

```bash
   $ git clone https://github.com/molejar/emLinux.git
   $ cd emLinux
   $ sudo ./install.sh
```

In Debian based distributions you can jump previous step and install directly the package `emlinux-tools_x.x.x_all.deb`
from [dpkg](dpkg) directory with a command:

```bash
   $ dpkg -i emlinux-tools_x.x.x_all.deb
```

If you are using Windows OS or non Debian based distribution, then you will need to use Virtual Machine. I have created a Vagrant script which will do all the work for you. Please, continue here: [Virtual Machine Builder](docs/emlinux_vm.md)

## Usage

The following picture is visualizing general usage of this automatization scripts. As you can see from picture, every script is covering a specific role in image build process and is accessible as standard shell command.

<p align="center">
  <img src="docs/images/emlinux_tools_bd.png" alt="Embedded Linux Tools"/>
</p>

***All implemented commands:***

* **build_toolchain** - *Prepare toolchain for barebox, uboot and kernel building*
* **build_barebox** - *Build BareBox Bootloader (replacement of U-Boot)*
* **build_uboot** - *Build U-Boot Bootloader from sources in git repo*
* **build_kernel** - *Build Kernel from sources in git repo*
* **build_rootfs** - *Build munimal RootFS based on Debian packages*
* **build_image** - *Create SD Card image from uboot, kernel and rootfs*

---

#### Build Toolchain:

```bash
Usage: ./build_toolchain [options]

Toolchain build script for i.MX (NXP MPU)

OPTIONS:
   -h/--help   Show this message
   -x          Use XDialog
   -v          Verbose
```

<br />

#### Build U-Boot Bootloader:

```bash
Usage: ./build_uboot [options] [params]

U-Boot build script for i.MX (NXP MPU)
   - use "mydata" dir for own data like patches, configs and sources

OPTIONS:
   -h/--help   Show this message
   -u/--updt   Clean sources and update local branch
   -c/--clean  Clean sources (remove all uncomited changes)
   -p/--patch  Create patch from working sources
   -m/--mcfg   Run menuconfig
   -x          Use XDialog
   -v          Verbose (print debug info)

PARAMS:
   -s/--surl   Set GitRepo URL for U-Boot SRC (optional)
   -t/--btool  Set path for external toolchain (optional)
```

<br />

#### Build Linux Kernel:

```bash
Usage: ./build_kernel [options] [params]

Linux Kernel build script for i.MX (NXP MPU)
   - use "mydata" dir for own patches, configs and sources

OPTIONS:
   -h/--help   Show this message
   -u/--updt   Clear sources and update local branch
   -c/--clean  Clean sources (remove all uncomited changes)
   -p/--patch  Create patch from working sources
   -z/--zip    Compress build data into zip archive
   -m/--mcfg   Run menuconfig
   -f          Include firmwares
   -x          Use XDialog
   -v          Verbose (print debug info)

PARAMS:
   -i/--img    Set Image Type (Image, uImage or zImage <default>)
   -s/--surl   Set GitRepo URL for Linux SRC (optional)
   -t/--btool  Set path for external toolchain (optional)
   -a/--laddr  Set target LOADADDR as "0x........" (optional)
```

<br />

#### Build RootFS from Debian or Ubuntu packages:

```bash
Usage: ./build_rootfs [options] [params]

RootFS creator script for i.MX (NXP MPU)
  - use "mydata" dir for aditional files

OPTIONS:
   -h/--help   Show this message
   -i          Create initial config and exit
   -n          New build, ignore initial config
   -x          Use XDialog
   -v          Verbose

PARAMS:
   -o/--out    Extract rootfs into specified directory
```

<br />

#### Build SD Card Image:

```bash
Usage: ./build_image [options] [params]

SDCard image creator script for i.MX (NXP MPU)
  - use "uboot"  dir for bootloader image and env
  - use "kernel" dir for kernel image and *.dtb files
  - use "rootfs" dir for rootfs pkgs or rawdata

OPTIONS:
   -h/--help   Show this message
   -i/--init   Create required dirs and exit
   -e/--extr   Extract SD Card Image <path to image>
   -c          Comress SD image: zip or gzip (default: zip)
   -x          Use XDialog
   -v          Verbose

PARAMS:
   -s/--sfatp  Set FAT16 partition size in MB (default: 20)
   -f/--sfree  Set RootFS free space in MB (default: 200)
```

<p align="center">
  <img src="docs/images/sd_image.png" alt="2GB SD-Cart Image Format"/>
  <br />
  <strong>Example of SD-Card Image Format (2GB)</strong>
</p>

## TODO

- Add i.MX GPU support into generated rootfs
- Add configuration wizard into build_toolchain script
- Update build_barebox script

## Usefull Links

* [Debian Quality Assurance](https://piuparts.debian.org)







