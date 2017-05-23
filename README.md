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

In Debian based distributions just install the package `emlinux-tools_<version>_all.deb` from release section.

```bash
   $ wget --quiet https://github.com/molejar/emLinux/releases/download/v<version>/emlinux-tools_<version>_all.deb
   $ sudo dpkg -i emlinux-tools_<version>_all.deb
```

If you are using Windows OS or non Debian based distribution, then you will need to use Virtual Machine. I have created a Vagrant script which will do all the work for you. Download the `emlinux-vm_<version>.zip` from release section and extract it into your disk. Then continue here: [Virtual Machine Builder](https://github.com/molejar/emLinux/wiki/VM)

## Usage

The following picture is visualizing general usage of this automatization scripts. As you can see from picture, every script is covering a specific role in image build process and is accessible as standard shell command.

<p align="center">
  <img src="docs/images/emlinux_tools_bd.png" alt="Embedded Linux Tools"/>
</p>

***Implemented commands:***

* **build_toolchain** - *Prepare toolchain for barebox, uboot and kernel building*
* **build_barebox** - *Build BareBox Bootloader (replacement of U-Boot)*
* **build_uboot** - *Build U-Boot Bootloader from sources in git repo*
* **build_kernel** - *Build Kernel from sources in git repo*
* **build_rootfs** - *Build munimal RootFS based on Debian packages*
* **build_image** - *Create SD Card image from uboot, kernel and rootfs*

For more details go to [Wiki](https://github.com/molejar/emLinux/wiki).

## Development

Clone this repository into your disk and install it with `install.sh` script.

```bash
   $ git clone https://github.com/molejar/emLinux.git
   $ cd emLinux
   $ sudo ./install.sh
```

## TODO

- Add i.MX GPU support into generated rootfs
- Add configuration wizard into build_toolchain script
- Update build_barebox script

## Usefull Links

* [Debian Quality Assurance](https://piuparts.debian.org)







