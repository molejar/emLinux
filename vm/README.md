# Embedded Linux VM

Embedded Linux VM is a Virtual Machine for local embedded Linux development, build with Vagrant tool

This project aims to make spinning up a simple local development environment incredibly quick and easy for i.MX platforms.
It should take 5-10 minutes to build or rebuild the VM from scratch with minimal interaction from user side.  

## Dependencies

You must have installed the following software in your host OS:

-  [VirtualBox](https://www.virtualbox.org/) - General-purpose full virtualizer for x86 hardware, targeted at server, desktop and embedded use.
-  [Vagrant](https://www.vagrantup.com/) - Create and configure lightweight, reproducible, and portable development environments.
-  [Git](https://git-scm.com/downloads) - Free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.


## How to Start

Clone this repository into your local disk and navigate to `emLinux/vm` directory in a terminal.
> In Windows I recommend use the Git BASH instead of CMD

Install vagrant plugin for adding virtualbox guest support in Windows OS
> Run it only first time after instaling Vagrant application

```bash
  $ vagrant plugin install vagrant-vbguest
```

Run the following command to bring the Vagrant virtual machine box (VM-Box) up and provision it for compiling the tools:

```bash
  $ vagrant up
```

If you change any Vagrant settings (e.g. changing the memory in the VM-Box) you'll need to reload the box with the following command:

```bash
  $ vagrant reload
```

After the virtual machine is brought up and provisioned use the following command to enter an SSH session on it:

```bash
  $ vagrant ssh
```

For exiting from SSH session just push `Ctrl+D` keys or run command:

```bash
  $ logout
```

For temporarily shutdown the VM-Box use the following command:

```bash
  $ vagrant halt
```

To delete the VM-Box and the data it contains run the following command:

```bash
  $ vagrant destroy
```

> Use it with caution!. When you run `vagrant up` again your VM box will be completely fresh.


## How to Customize VM-Box

The default configuration for VM is stored in `default.conf` file and is using the YAML syntax. You can edit it directly or create a local configuration file `local.conf` with customized settings.


## FAQ

**Machine does't start if run `vagrant up`:**<br>
*Sometine it takes longer time to start up the machine and vagrant finish with error. Just rerun the `vagrant up` command.*
<br>
<br>
**In Windows I'm not able connect to SAMBA share:**<br>
*The hostname must be unique on the same network, else can collide with other machines.*

