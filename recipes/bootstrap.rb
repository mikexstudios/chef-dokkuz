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
default['docker']['group_members'] = ['dokku', ]

include_recipe 'docker' #default installation type is package


# Install stack
include_recipe 'dokku::buildstep'


# Install dokku files (i.e. copyfiles)
include_recipe "dokku::install"


# Install plugins
include_recipe 'dokku::plugins'


include_recipe 'dokku::apps'

#set VHOST
domain = node['dokku']['domain'] || node['fqdn']
file File.join(node['dokku']['root'], 'VHOST') do
  content domain
end

include_recipe "dokku::ssh_keys"

# Reload nginx
service 'nginx' do
  action :reload
end
