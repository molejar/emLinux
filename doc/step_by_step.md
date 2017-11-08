emLinux in Windows OS
=====================

This tutorial will guide you step-by-step into embedded Linux development under Windows OS.

# 1. Install Dependencies

The following tools must be installed in your PC running Windows OS.

- [VirtualBox](https://www.virtualbox.org/) - General-purpose full virtualizer for x86 hardware, targeted at server, 
desktop and embedded use.
- [Vagrant](https://www.vagrantup.com/) - Create and configure lightweight, reproducible, and portable development 
environments. In **Windows 7** use version **1.9.6**, because all upper versions could be unstable.
- [pyIMX](https://github.com/molejar/pyIMX) - Collection of useful tools for IMX processors (Smart-Boot, ...)

# 2. Prepare virtual machine

- Download archive with Vagrant script [emlinux-wm](https://github.com/molejar/emLinux/releases/download/0.1.1/emlinux-vm_0.1.1.zip)
and extract it to local disk.
- Set unique host name, machine name and other settings for generated VM in `local.conf` file. 
- Open shell in extracted directory and execute command:
```
  $ vagrant up
```
> If your PC has more than one network adapter, then select the right for internet access. 
- After the VM is brought up and provisioned use following command to open SSH session on it.
```
  $ vagrant ssh
```
> More details about Vagrant tool and its other commands are described on [wiki page](https://github.com/molejar/emLinux/wiki/VM).

# 3. Build toolchain (optional)

- Run **build_toolchain** command and follow the wizard:

```
  $ build_toolchain
```

> This step is optional because VM has preinstalled toolchain. Go into it only if you need customize the toolchain build.

# 4. Build U-Boot

- Create empty directory **uboot** and navigate to it
```
  $ mkdir uboot && cd uboot
```
- Run **build_uboot** command and follow the wizard:
```
  $ build_uboot

***********************************************************
*                     U-Boot Builder                      *
***********************************************************

 For printing all usable options use "build_uboot -h"

[INFO ] Searching Compiler, please wait !
[INFO ] Used Compiler: /usr/bin/arm-linux-gnueabihf-gcc

------------------------------------------------------------
 Select source repository 
------------------------------------------------------------
 0) http://sw-stash.freescale.net/scm/imx/uboot-imx.git
 1) git://git.freescale.com/imx/uboot-imx.git
 2) https://github.com/Freescale/u-boot-fslc.git
 3) git://git.denx.de/u-boot.git

 x) Exit
------------------------------------------------------------
Enter: 2

Cloning into '/home/ubuntu/uboot/source'...
...

------------------------------------------------------------
 Select option for git checkout list 
------------------------------------------------------------
 0) BRANCH
 1) TAG
 2) ALL

 x) Exit
------------------------------------------------------------
Enter: 0

------------------------------------------------------------
 Select Branch 
------------------------------------------------------------
 ...
 10) 2017.07+fslc
 11) 2017.09+fslc
 12) 2017.11+fslc
 ...
 x) Exit
------------------------------------------------------------
Enter: 12

------------------------------------------------------------
 Supported Boards 
------------------------------------------------------------
 ...
 38) mx7dsabresd
 39) mx7dsabresd_secure
 40) mx7ulp_evk
 ...
 x) Exit
------------------------------------------------------------
Enter: 39

make[1]: Entering directory '/home/ubuntu/uboot/.cache'
  HOSTCC  scripts/basic/fixdep
  GEN     ./Makefile
  HOSTCC  scripts/kconfig/conf.o
  SHIPPED scripts/kconfig/zconf.tab.c
  ...
  
---------------------------------------------------------------
        Congratulations, U-Boot build was successful
---------------------------------------------------------------
 Created files are stored in:
 /home/ubuntu/uboot/build/imx7dsabresd_secure
---------------------------------------------------------------
```
> More details are on [wiki page](https://github.com/molejar/emLinux/wiki/Commands#build_uboot).

# 5. Build Kernel

- Create empty directory **kernel** and navigate to it
```
  $ mkdir kernel && cd kernel
```
- Run **build_kernel** command and follow the wizard:
```
  $ build_kernel
  
***********************************************************
*               Linux Kernel Builder                      *
***********************************************************

 For printing all usable options use "build_kernel -h"

[INFO ] Searching Compiler, please wait !
[INFO ] Used Compiler: /usr/bin/arm-linux-gnueabihf-gcc

------------------------------------------------------------
 Select source repository 
------------------------------------------------------------
 0) http://sw-stash.freescale.net/scm/imx/linux-2.6-imx.git
 1) git://git.freescale.com/imx/linux-imx.git
 2) https://github.com/Freescale/linux-fslc
 3) https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

 x) Exit
------------------------------------------------------------
Enter: 2

Cloning into '/home/ubuntu/kernel/source'...
...

------------------------------------------------------------
 Select option for git checkout list 
------------------------------------------------------------
 0) BRANCH
 1) TAG
 2) ALL

 x) Exit
------------------------------------------------------------
Enter: 0

------------------------------------------------------------
 Select Branch 
------------------------------------------------------------
 ...
 13) 4.8.x+fslc
 14) 4.9-1.0.x-imx
 15) 4.9.x+fslc
 x) Exit
------------------------------------------------------------
Enter: 14

------------------------------------------------------------
 Supported Boards 
------------------------------------------------------------
 ...
 232) imx7d-sdb
 233) imx7d-sdb-epdc
 234) imx7d-sdb-gpmi-weim
 ...
 x) Exit
------------------------------------------------------------
Enter: 232

------------------------------------------------------------
 Add to defcofig 
------------------------------------------------------------
 0) SystemD
 1) open_source_GPU_and_VPU
 2) SystemD+open_source_GPU_and_VPU
 3) Nothing

 x) Exit
------------------------------------------------------------
Enter: 0

make[1]: Entering directory '/home/ubuntu/kernel/.cache'
  HOSTCC  scripts/basic/fixdep
  GEN     ./Makefile
  HOSTCC  scripts/kcon
  ...
  
---------------------------------------------------------------
         Congratulations, Kernel build was successful
---------------------------------------------------------------
 Created files are stored in:
 /home/ubuntu/kernel/build/imx7d-sdb
---------------------------------------------------------------
```
> More details are on [wiki page](https://github.com/molejar/emLinux/wiki/Commands#build_kernel).

# 6. Build RootFS

- Create empty directory **rootfs** and navigate to it
```
  $ mkdir rootfs && cd rootfs
```
- Run **build_rootfs** command and follow the wizard:
```
  $ sudo build_rootfs
  
***********************************************************
*                     RootFS Creator                      *
***********************************************************

 For printing all usable options use "build_rootfs -h"


------------------------------------------------------------
 Select Board 
------------------------------------------------------------
 ...
 10) imx6ul-evk
 11) imx6ull-evk
 12) imx7d-sdb

 x) Exit
------------------------------------------------------------
Enter: 12

------------------------------------------------------------
 Select Distribution 
------------------------------------------------------------
 0) debian-jessie
 1) debian-wheezy
 2) ubuntu-zesty
 3) ubuntu-xenial
 4) ubuntu-lucid

 x) Exit
------------------------------------------------------------
Enter: 1

==> Installing debian into /home/ubuntu/rootfs/temp
I: Retrieving InRelease 
...

---------------------------------------------------------------
         Congratulations, RootFS build was successful
---------------------------------------------------------------
 /home/ubuntu/rootfs/build/imx7d-sdb_debian_wheezy_rootfs.tar.gz
---------------------------------------------------------------
```

> More details are on [wiki page](https://github.com/molejar/emLinux/wiki/Commands#build_rootfs).

# 7. Test generated embedded Linux OS

> TODO

# 8. Create SD Card Image (optional)

- Create empty directory for image build and navigate to it
```
  $ mkdir rootfs && cd rootfs
```
- Create required subdirectories
```
  $ build_image -i
```
- Copy u-boot, kernel and rootfs into created subdirectories
```
  $ cp ../uboot/build/imx7dsabresd/u-boot.imx uboot/
  $ cp ../kernel/build/imx7d-sdb/zImage kernel/
  $ cp ../kernel/build/imx7d-sdb/*.dtb kernel/
  $ cp ../kernel/build/imx7d-sdb/rootfs/* rootfs/mydata/
  $ cp ../rootfs/ rootfs/
```
- Run **build_image** command for building SD Card image
```
  $ sudo build_image 

************************************************************
*                   SD Card Image Creator                  *
************************************************************

 For printing all usable options use "build_image -h"


[INFO] Calculating the Image size ..................... Done
[INFO] Creating empty sdcard.img file ................. Done
[INFO] Creating MBR and partitions in sdcard.img ...... Done
[INFO] Copy u-boot into sdcard.img .................... Done
[INFO] Format FAT16 partition and copy Kernel + DTS ... Done
[INFO] Format EXT4  partition and copy rootfs data .... Done

------------------------------------------------------------
     Congratulations, SD Card image successfully created
------------------------------------------------------------
 Name: sdcard.img | Size: 829 MB | Free: 200 MB
------------------------------------------------------------
```

> More details are on [wiki page](https://github.com/molejar/emLinux/wiki/Commands#build_image).

##### Write image into sdcard with **`dd`** command inside VM:
```
  $ sudo dd if=sdcard.img of=/dev/mmcblk0  
```

##### Write image into sdcard with [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) inside Windows OS:

- copy generated from VM into shared directory on PC
```
  $ sudo cp sdcard.img /vagrant  
```

...
