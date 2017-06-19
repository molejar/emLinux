# -*- mode: ruby -*-
# vi: set ft=ruby :

# required modules
require 'yaml'

# *********************************************************************************************
# Local Methods
# *********************************************************************************************

def get_ansible_version(exe)
  /^[^\s]+ (.+)$/.match(`#{exe} --version`) { |match| return match[1] }
end

def walk(obj, &fn)
  if obj.is_a?(Array)
    obj.map { |value| walk(value, &fn) }
  elsif obj.is_a?(Hash)
    obj.each_pair { |key, value| obj[key] = walk(value, &fn) }
  else
    obj = yield(obj)
  end
end

# *********************************************************************************************
# Local Variables
# *********************************************************************************************

# Fix ENV['VBOX_INSTALL_PATH'] in Windows OS
if Vagrant::Util::Platform.windows?
  ENV['VBOX_INSTALL_PATH'] = ENV['VBOX_MSI_INSTALL_PATH']
end

# Absolute paths on the host machine.
host_project_dir = File.dirname(File.expand_path(__FILE__))
host_config_dir = ENV['LINUXVM_CONFIG_DIR'] ? "#{host_project_dir}/#{ENV['LINUXVM_CONFIG_DIR']}" : host_project_dir

# Absolute paths on the guest machine.
guest_project_dir = '/vagrant'
guest_config_dir = ENV['LINUXVM_CONFIG_DIR'] ? "/vagrant/#{ENV['LINUXVM_CONFIG_DIR']}" : guest_project_dir

# Custom configuration
linuxvm_config = ENV['LINUXVM_CONFIG_FILE'] || 'vagrant'

# Load default VM configurations.
vconfig = YAML.load_file("#{host_project_dir}/default.conf")

# Use optional user.conf and local.conf for configuration overrides.
['user.conf', 'local.conf', "#{linuxvm_config}"].each do |config_file|
  if File.exist?("#{host_config_dir}/#{config_file}")
    cfg_data = YAML.load_file("#{host_config_dir}/#{config_file}")
    if cfg_data then vconfig.merge!(cfg_data) end
  end
end

# Replace jinja variables in config.
vconfig = walk(vconfig) do |value|
  while value.is_a?(String) && value.match(/{{ .* }}/)
    value = value.gsub(/{{ (.*?) }}/) { vconfig[Regexp.last_match(1)] }
  end
  value
end

# EmLinux Tools Version
emlinux_version = vconfig['vm_emlinux']

# Get Host Name and Machine Name
hostname = vconfig['vm_hostname']
machname = vconfig.include?('vm_machname') ? vconfig['vm_machname'] : hostname

# Check Vagrant version
Vagrant.require_version ">= 1.8.6"

# Configuration
Vagrant.configure(2) do |config|

  # Vagrant box.
  config.vm.box = vconfig['vagrant_box']

  # The url from where the 'config.vm.box' box will be fetched if it doesn't already exist.
  if vconfig.include?('vagrant_url')
    config.vm.box_url = vconfig['vagrant_url']
  end
 
  # Set machine name
  config.vm.define machname

  # Set machine disk size
  if vconfig.include?('vm_disksize')
    unless Vagrant.has_plugin?('vagrant-disksize')
        puts "'vagrant-disksize' plugin is required. Install it by running:"
        puts " vagrant plugin install vagrant-disksize"
        puts
        exit
    end

    config.disksize.size = "#{vconfig['vm_disksize']}GB"
  end
  
  # *********************************************************************************************
  # Network options.
  # *********************************************************************************************

  # Network Host Name.
  config.vm.hostname = hostname

  # Network Config
  if vconfig.include?('vm_networks')
    vconfig['vm_networks'].each do |network|
      if network['enabled'] && network['enabled'] == true
        options = {}

        if network.include?('ip')
          options[:ip] = network['ip']
        end

        if network.include?('bridge')
          options[:bridge] = network['bridge']
        end

        if network.include?('dhcp_defroute')
          options[:use_dhcp_assigned_default_route] = network['dhcp_defroute']
        end

        if options
          config.vm.network network['access'], options
        else
          config.vm.network network['access']
        end
      end
    end
  end

  # *********************************************************************************************
  # SSH options.
  # *********************************************************************************************

  # Use correct user name and password for SSH access
  if ARGV[0] == "ssh"
    config.ssh.username = vconfig['vm_username']
    config.ssh.password = vconfig['vm_userpass']
  end

  # Vagrant will automatically insert a keypair to use for SSH (default: true).
  config.ssh.insert_key = true
  # Use Vagrant-provided SSH private keys (don't use any keys stored in ssh-agent, default: true).
  config.ssh.keys_only = true
  # Use agent forwarding over SSH connections (default: false).
  config.ssh.forward_agent = true
  # Use X11 forwarding over SSH connections (default: false).
  config.ssh.forward_x11 = false

  # *********************************************************************************************
  # Synced folders
  # *********************************************************************************************
  
  # Default synced folder
  if Vagrant::Util::Platform.windows?
    config.vm.synced_folder host_project_dir, guest_project_dir, type: "virtualbox"
  else
    config.vm.synced_folder host_project_dir, guest_project_dir
  end 

  # User defined synced folders
  if vconfig.include?('vm_folders')
    vconfig['vm_folders'].each do |synced_folder|
      if synced_folder['enabled'] && synced_folder['enabled'] == true
        config.vm.synced_folder synced_folder['local_path'], synced_folder['dest_path'], {
          type: synced_folder['type'],
          rsync__auto: 'true',
          rsync__exclude: synced_folder['exclude'],
          rsync__args: ['--verbose', '--archive', '--delete', '-z', '--chmod=ugo=rwX'],
          id: synced_folder['id'],
          create: synced_folder.include?('create') ? synced_folder['create'] : false,
          mount_options: synced_folder.include?('mount_opts') ? synced_folder['mount_opts'] : []
        }
      end
    end
  end

  # *********************************************************************************************
  # Persistent storage.
  # *********************************************************************************************

  if vconfig.include?('vm_pstorage')
    pstorage = vconfig['vm_pstorage']

    if pstorage.include?('enabled') && pstorage['enabled'] == true
      unless Vagrant.has_plugin?('vagrant-persistent-storage')
        puts "'vagrant-persistent-storage' plugin is required. Install it by running:"
        puts " vagrant plugin install vagrant-persistent-storage"
        puts
        exit
      end

      config.persistent_storage.enabled = true
      config.persistent_storage.mountname = 'pstorage'
      config.persistent_storage.size = pstorage['size']
      config.persistent_storage.location = pstorage['location']
      config.persistent_storage.filesystem = pstorage['fstype']
      config.persistent_storage.mountpoint = pstorage['destpath']
      config.persistent_storage.use_lvm = false
      if pstorage.include?('mopts')
        config.persistent_storage.mountoptions = pstorage['mopts']
      end
    end
  end

  # *********************************************************************************************
  # Virtualbox settings
  # *********************************************************************************************

  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.installer_arguments = "--nox11 -- --force"
    config.vbguest.auto_update = true
    # config.vbguest.iso_path = 'http://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso' #% {version: '5.1.14'}
    # config.trigger.after :up { run "vagrant vbguest --auto-reboot --no-provision" }
  else
    if Vagrant::Util::Platform.windows?
      puts "'vagrant-vbguest' plugin is required. Install it by running:"
      puts " vagrant plugin install vagrant-vbguest"
      puts
      exit
    end
  end

  # Set VirtualBox.
  config.vm.provider :virtualbox do |vb|
    if Vagrant::VERSION =~ /^1.8/
      vb.linked_clone = true
    end

    vb.name = hostname
    vb.memory = vconfig.include?('vm_memory') ? vconfig['vm_memory'] : 1024
    vb.cpus = vconfig.include?('vm_cpus') ? vconfig['vm_cpus'] : 1
    vb.gui = vconfig.include?('vm_gui') ? vconfig['vm_gui'] : false

    # Customize provider default configuration
    # - make the DNS resolution faster
    # - enable USB support
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnshostresolver2', 'on']
    vb.customize ['modifyvm', :id, '--ioapic', 'on']
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
    #vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    if vconfig.include?('vm_gui') && vconfig['vm_gui'] == true
      vb.customize ["modifyvm", :id, "--vram", "32"]
    end
  end

  # *********************************************************************************************
  # Scripts
  # *********************************************************************************************

  $init_script = <<-'END'
    sudo apt-get update -y
    #sudo apt-get upgrade -y
    sudo apt-get install -y build-essential ncurses-dev
    sudo apt-get install -y gcc-arm-linux-gnueabi 
    sudo apt-get install -y u-boot-tools qemu-user-static
    sudo apt-get install -y debian-keyring debian-archive-keyring
    echo '>>> Set password for %{username} user to %{userpass}'
    echo '%{username}:%{userpass}' | sudo chpasswd
  END

  if Vagrant::Util::Platform.windows?
    $init_script += <<-'END'
      echo '>>> Install samba server'
      sudo apt-get install -y samba
      echo '[global]'                                   > /etc/samba/smb.conf
      echo '    workgroup = WORKGROUP'                 >> /etc/samba/smb.conf
      echo '    server string = Samba server (Ubuntu)' >> /etc/samba/smb.conf
      echo '    server role = standalone server'       >> /etc/samba/smb.conf
      echo '    guest account = %{username}'           >> /etc/samba/smb.conf
      echo '    admin users = %{username}'             >> /etc/samba/smb.conf
      echo '    unix password sync = yes'              >> /etc/samba/smb.conf
      echo '    map to guest = bad user'               >> /etc/samba/smb.conf
      echo '    usershare allow guests = yes'          >> /etc/samba/smb.conf
      echo '    dns proxy = no'                        >> /etc/samba/smb.conf
      echo '[%{username}]'                             >> /etc/samba/smb.conf
      echo '    comment = Share'                       >> /etc/samba/smb.conf
      echo '    path = /home/%{username}'              >> /etc/samba/smb.conf
      echo '    browsable = yes'                       >> /etc/samba/smb.conf
      echo '    guest ok = yes'                        >> /etc/samba/smb.conf
      echo '    read only = no'                        >> /etc/samba/smb.conf
      echo '    create mask = 0777'                    >> /etc/samba/smb.conf
      echo '    directory mask = 0777'                 >> /etc/samba/smb.conf
      sudo systemctl restart smbd.service nmbd.service
      echo '>>> Install emlinux-tools dependencies'
      sudo apt-get install -y git parted tree lzop gzip zip bc binfmt-support debootstrap
      echo '>>> Install emlinux-tools'
      sudo wget --quiet https://github.com/molejar/emLinux/releases/download/%{emlinux_tools_release}/emlinux-tools_%{emlinux_tools_release}_all.deb
      sudo dpkg -i emlinux-tools_%{emlinux_tools_release}_all.deb
      sudo rm emlinux-tools_%{emlinux_tools_release}_all.deb
    END
  else
    $init_script += <<-'END'
      echo '>>> Install emlinux-tools dependencies'
      sudo apt-get install -y git parted tree lzop gzip zip bc binfmt-support debootstrap
      echo '>>> Install emlinux-tools'
      sudo chmod a+x %{emlinux_tools_install}
      sudo %{emlinux_tools_install} -q
    END
  end

  $init_script += <<-'END'
    echo '>>> Install tftp server'
    sudo apt-get install -y tftpd-hpa
    echo 'TFTP_USERNAME="tftp"'                        >> /etc/default/tftpd-hpa
    echo 'TFTP_DIRECTORY="%{tftpdir}"'                 >> /etc/default/tftpd-hpa
    echo 'TFTP_ADDRESS="[::]:69"'                      >> /etc/default/tftpd-hpa
    echo 'TFTP_OPTIONS="--secure --create"'            >> /etc/default/tftpd-hpa
    sudo mkdir -p %{tftpdir}
    sudo chown -R tftp %{tftpdir}
    sudo systemctl restart tftpd-hpa.service
    echo '>>> Install nfs server'
    sudo apt-get install -y nfs-kernel-server nfs-common portmap
    echo '%{nfsdir} *(rw,async,nohide,insecure,no_subtree_check,no_root_squash)' >> /etc/exports
    sudo mkdir -p %{nfsdir}
    sudo /etc/init.d/nfs-kernel-server restart
    sudo systemctl restart nfs-kernel-server.service
    sudo chown -R %{username}:%{username} /home/%{username}
  END

  # Execute initialization script
  config.vm.provision "shell", inline: $init_script % {
    :nfsdir  => "/srv/nfs",
    :tftpdir => "/srv/tftp",
    :username => vconfig['vm_username'],
    :userpass => vconfig['vm_userpass'],
    :emlinux_tools_install => "#{guest_project_dir}/install.sh",
    :emlinux_tools_release => "#{emlinux_version}"
  }

  # Execute bootstrap script
  if vconfig.include?('vm_bootstrap')
    script = ""
    vconfig['vm_bootstrap'].each { |cmd| script += "#{cmd}\n" }
    script += 'echo ">>> VM Ready, run: vagrant ssh"'
    config.vm.provision "shell", inline: script
  end
end
