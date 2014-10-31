# Install 00_dokku-standard 
file "#{node['dokku']['plugin_path']}/00_dokku-standard/install" do
  action :delete
end

## NOTE: nginx plugin duplicates this for 'VHOST'
domain = node['dokku']['domain'] || node['fqdn']
file File.join(node['dokku']['root'], 'HOSTNAME') do
  content domain
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
  user 'root'
  commands ['/etc/init.d/nginx reload']
  nopasswd true
end

template "/etc/nginx/conf.d/dokku.conf" do
  source 'plugins/nginx-vhosts/dokku.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

## NOTE: 00_dokku-standard plugin duplicates this for 'HOSTNAME'
domain = node['dokku']['domain'] || node['fqdn']
file File.join(node['dokku']['root'], 'VHOST') do
  content domain
end


# Remove backup plugin since the chef cookbook should contain all information
# needed to recreate the app.
directory "#{node['dokku']['plugin_path']}/backup" do
  action :delete
  recursive true
end


# Remove config plugin since any environment variables should be configured by
# chef.
directory "#{node['dokku']['plugin_path']}/config" do
  action :delete
  recursive true
end


# Remove git plugin since all deploys will occur using LWRPs
directory "#{node['dokku']['plugin_path']}/git" do
  action :delete
  recursive true
end


# Install user defined plugins
node['dokku']['plugins'].each do |name, settings|
  git "#{node['dokku']['plugin_path']}/#{name}" do
    repository settings['repository'] 
    revision settings['revision'] if settings['revision']
    action node['dokku']['sync']['plugins'] ? :sync : :checkout
  end
end

# TODO: Manually call each plugin's install hook in the above loop and provide
# the option to override it instead of calling all of the plugin installs at
# once.
bash "dokku_plugins_install" do
  cwd node['dokku']['plugin_path']
  code <<-EOH
    dokku plugins-install
  EOH
  only_if { node['dokku']['sync']['plugins'] }
end
