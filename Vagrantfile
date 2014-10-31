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

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network 'private_network', ip: DOKKU_IP

  config.vm.provider 'virtualbox' do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ['modifyvm', :id, '--memory', '512']
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
        }
      }
    }
  end
end
