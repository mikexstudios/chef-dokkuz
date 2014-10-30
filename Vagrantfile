# -*- mode: ruby -*-
# vi: set ft=ruby :
# NOTE: Before running `vagrant up`, install the following plugins:
# vagrant plugin install vagrant-omnibus (required to install chef server)
# vagrant plugin install vagrant-berkshelf --plugin-version '>= 2.0.1'

# Dokku test domains that will be mapped to private IP of VM.
DOKKU_IP = ENV['DOKKU_IP'] || '10.0.0.2'
# We use xip.io to automatically create wildcard (*.10.0.0.2.xip.io) 
# subdomains that point to a private IP. This is important because
# wildcard subdomains cannot be achieved locally without running a DNS
# server (can't do it with /etc/hosts).
DOKKU_DOMAIN = ENV['DOKKU_DOMAIN'] || "#{DOKKU_IP}.xip.io"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Plugins
  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = 'ubuntu/trusty64' #see vagrantcloud.com

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network 'private_network', ip: DOKKU_IP

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider 'virtualbox' do |vb|
    # Don't boot with headless mode
    # vb.gui = true
  
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ['modifyvm', :id, '--memory', '1024']
    vb.customize ['modifyvm', :id, '--cpus', '1']
  end

  config.vm.provision 'chef_solo' do |chef|
    #chef.cookbooks_path = '../my-recipes/cookbooks'
    #chef.roles_path = '../my-recipes/roles'
    #chef.data_bags_path = '../my-recipes/data_bags'
    chef.add_recipe 'dokku::install'
    #chef.add_role 'web'
  
    # You may also specify custom JSON attributes:
    chef.json = {
      dokku: {
        domain: DOKKU_DOMAIN,
        apps: {
          hello: {
            env: { 'NAME' => 'vagrant' }
          }
        },
        ssh_keys: {
          vagrant: 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key'
        }
      }
    }
  end
end
