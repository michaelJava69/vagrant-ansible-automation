# Defines our Vagrant environment
#
# -*- mode: ruby -*-
# vi: set ft=ruby :

# -*- mode: ruby -*-
NUMBER_OF_WEBSERVERS = 2
CPU = 2
MEMORY = 256
ADMIN_USER = "vagrant"
ADMIN_PASSWORD = "vagrant"
VM_VERSION= "ubuntu/trusty64"
#VM_VERSION= "https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
VAGRANT_VM_PROVIDER = "virtualbox"



Vagrant.configure("2") do |config|

  # create mgmt node
  config.vm.define :mgmt do |mgmt_config|
      mgmt_config.vm.box = VM_VERSION
      mgmt_config.vm.hostname = "mgmt"
      mgmt_config.vm.network :private_network, ip: "10.0.15.10"
      mgmt_config.vm.provider VAGRANT_VM_PROVIDER do |vb|
        vb.memory = MEMORY
      end
       
      mgmt_config.vm.provision :shell, path: "bootstrap-mgmt.sh"
  end

  # create load balancer
  config.vm.define :lb do |lb_config|
      lb_config.vm.box = VM_VERSION
      lb_config.vm.hostname = "lb"
      lb_config.vm.network :private_network, ip: "10.0.15.11"
      lb_config.vm.network "forwarded_port", guest: 80, host: 8080
      lb_config.vm.provider VAGRANT_VM_PROVIDER do |vb|
        vb.memory = MEMORY
      end
  end

  # create some web servers
  # https://docs.vagrantup.com/v2/vagrantfile/tips.html
  (1..NUMBER_OF_WEBSERVERS).each do |i|
    config.vm.define "web#{i}" do |node|
        node.vm.box = VM_VERSION
        node.vm.hostname = "web#{i}"
        node.vm.network :private_network, ip: "10.0.15.2#{i}"
        node.vm.network "forwarded_port", guest: 80, host: "808#{i}"
        node.vm.provider VAGRANT_VM_PROVIDER do |vb|
          vb.memory = MEMORY
        end
    end
  end

end
