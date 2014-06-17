# This is essentially a chef version of: 
# https://github.com/progrium/dokku/blob/master/bootstrap.sh
# and
# https://github.com/progrium/dokku/blob/master/Makefile
# We are doing it this way so we can allow chef to install/configure some of
# our dependencies instead of allowing the bootstrap script to do it

# Cookbook deps
%w{apt git build-essential user ohai}.each do |dep|
  include_recipe dep
end

# Package deps
%w{software-properties-common dnsutils apt-transport-https}.each do |dep|
  package dep
end

## dependencies: sshcommand pluginhook docker stack

# Install sshcommand
sshcommand_path = "#{Chef::Config[:file_cache_path]}/sshcommand"

remote_file sshcommand_path do
  source node['dokku']['sshcommand']['src_url']
  checksum '713b5bfc1ac944ce0544497f75a0dd3731196b4eb7e594e30630ea91b9a01c9d'
end

bash 'install_sshcommand' do
  cwd ::File.dirname(sshcommand_path)
  code <<-EOH
    cp sshcommand /usr/local/bin
    chmod +x /usr/local/bin/sshcommand
    sshcommand create dokku /usr/local/bin/dokku
  EOH
  only_if { node['dokku']['sync']['dependencies'] }
end


# Install pluginhook
pluginhook_name = node['dokku']['pluginhook']['filename']
pluginhook_path = "#{Chef::Config[:file_cache_path]}/#{pluginhook_name}"

remote_file pluginhook_path do
  source node['dokku']['pluginhook']['src_url']
  checksum '0a9f89ad3fd12fbeed604af8c01b0f6d3ab98e273c89a5495cd877e6a46ef8f3'
end

dpkg_package pluginhook_name do
  source pluginhook_path
  only_if { node['dokku']['sync']['dependencies'] }
end


# Install docker

## Setup storage driver 
case node['docker']['storage_driver']
when 'aufs'
  include_recipe 'aufs'
when 'devicemapper' #note: lack of dash
  include_recipe 'device-mapper'
else
  log 'Storage driver for docker not selected!' do
    level :warn
  end
end

## Create docker group with dokku as member
node.default['docker']['group_members'] = ['dokku', ]

include_recipe 'docker' #default installation type is package


# Install stack
include_recipe 'dokku::buildstep'


# Install dokku files 
include_recipe "dokku::copyfiles"


# Install plugins
include_recipe 'dokku::plugins'


# Install version file
bash 'install_version' do
  cwd "#{Chef::Config[:file_cache_path]}/dokku"
  code <<-EOH
    git describe --tags > #{node['dokku']['root']}/VERSION  2> /dev/null || \
    echo "~master ($(date -uIminutes))" > #{node['dokku']['root']}/VERSION
  EOH
end
