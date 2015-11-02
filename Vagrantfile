# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# YAML Module
require 'yaml'

# Defaults
$memory = 1024
$cpus = 2
$box = "cloudhotspot/ubuntu"

# Inventory file
$stack = YAML.load_file('vagrant.yml') || {}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Disable new SSH key generation - appears to solve similar issue to https://github.com/test-kitchen/kitchen-vagrant/issues/130
  config.ssh.insert_key = false

  # Fix for https://github.com/mitechellh/vagrant/issues/1673
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  $stack.each do |key,values|
    config.vm.define key do |config|
      config.vm.box = values["box"] || $box
      config.vm.hostname = key

      # AWS Settings
      config.vm.provider "aws" do |aws, override|
        aws_settings = values["aws"]
        aws.access_key_id = ENV['AWS_ACCESS_KEY']
        aws.secret_access_key = ENV['AWS_SECRET_KEY']
        aws.region = aws_settings["region"]
        aws.instance_type = aws_settings["instance_type"] || "t2.micro"
        aws.keypair_name = aws_settings["keypair_name"]
        aws.ami = aws_settings["ami"]
        aws.subnet_id = aws_settings["subnet_id"]
        aws.associate_public_ip = aws_settings["associate_public_ip"] || false
        aws.security_groups = aws_settings["security_groups"] || []
        aws.tags = aws_settings["tags"] || {}

        override.ssh.username = aws_settings["username"] || "ubuntu"
        override.ssh.private_key_path = aws_settings["private_key_path"] || "~/.ssh/id_rsa"
        override.nfs.functional = false
        override.vm.synced_folder ".", "/vagrant", disabled: true

        config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
          if hostname = (vm.ssh_info && vm.ssh_info[:host])
            `host #{hostname}`.match(/-([0-9]+)-([0-9]+)-([0-9]+)-([0-9]+)/) {|a,b,c,d| "#{a}.#{b}.#{c}.#{d}"}
          end
        end
      end

      # VMWare Fusion Settings
      config.vm.provider "vmware_fusion" do |v|
        v.vmx["memsize"] = values["memory"] || $memory
        v.vmx["numvcpus"] = values["cpu"] || $cpus
      end

      # Virtualbox Settings
      config.vm.provider "virtualbox" do |v|
        v.memory = $memory
        v.cpus = $cpus
      end

      # Network Settings
      if values["ip"]
        config.vm.network "private_network", ip: values["ip"]
      end

      # Folders
      folders = values["folders"] || []
      folders.each do |folder| 
        config.vm.synced_folder folder["host"], folder["guest"], type: folder["type"]
      end

      # Shell Provisioner
      shell = values["shell_provisioner"]
      if shell
        shell.each do |sh|
          sh.each do |sh_key,sh_value|
            config.vm.provision "shell", sh_key.to_sym => sh_value
          end
        end
      end

      # Docker Provisioner
      provisioner = values["docker_provisioner"]  
      if provisioner
        config.vm.provision "docker" do |d|
          run = provisioner["run"] || []
          run.each do |r|
            d.run r["name"], image: r["image"], args: r["args"], cmd: r["cmd"], daemonize: r["daemonize"] || true
          end
        end
      end
    end
  end

  # Add guests to host hosts file
  # config.hostmanager.enabled = true
  config.vm.provision :hostmanager
  config.hostmanager.manage_host = true
end
