# Install 00_dokku-standard 
file "#{node['dokku']['plugin_path']}/00_dokku-standard/install" do
  action :delete
end

## NOTE: nginx plugin duplicates this for 'VHOST'
domain = node['dokku']['domain'] || node['fqdn']
file File.join(node['dokku']['root'], 'HOSTNAME') do
  content domain
  action :create_if_missing
end

## temporary hack for https://github.com/progrium/dokku/issues/82
## redeploys all apps after a reboot
template "/etc/init/dokku-redeploy.conf" do
  source "plugins/00_dokku-standard/dokku-redeploy.conf"
  action :create
  owner 'root'
  group 'root'
  mode 0644
end


# Install nginx-vhosts

## The nginx install script does some stuff we don't want. Nuke it and do the
## install manually.
## Can be removed once https://github.com/progrium/dokku/pull/276 is merged
file "#{node['dokku']['plugin_path']}/nginx-vhosts/install" do
  action :delete
end

## Install nginx ahead of the plugin install so that it is chef managed
include_recipe 'nginx::repo' #use stable from http://nginx.org/en/download.html
include_recipe 'nginx'

## Clean up distribution configs
file '/etc/nginx/conf.d/example_ssl.conf' do
  action :delete
end
file '/etc/nginx/conf.d/default.conf' do
  action :delete
end

sudo 'dokku-nginx-reload' do
  user '%dokku'
  commands ['/etc/init.d/nginx reload']
  nopasswd true
end

template "/etc/nginx/conf.d/dokku.conf" do
  source 'plugins/nginx-vhosts/dokku.conf.erb'
  action :create_if_missing
  owner 'root'
  group 'root'
  mode 0644
end

## NOTE: 00_dokku-standard plugin duplicates this for 'HOSTNAME'
domain = node['dokku']['domain'] || node['fqdn']
file File.join(node['dokku']['root'], 'VHOST') do
  content domain
  action :create_if_missing
end


# Install user defined plugins
node['dokku']['plugins'].each do |name, settings|
  git "#{node['dokku']['plugin_path']}/#{name}" do
    repository settings['repository'] 
    revision settings['revision'] if settings['revision']
    action node['dokku']['sync']['plugins'] ? :sync : :checkout
  end
end

bash "dokku_plugins_install" do
  cwd node['dokku']['plugin_path']
  code <<-EOH
    dokku plugins-install
  EOH
  only_if { node['dokku']['sync']['plugins'] }
end
