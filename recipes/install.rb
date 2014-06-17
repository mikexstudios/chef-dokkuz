# From original Makefile:
#     install: dependencies stack copyfiles plugins version
# dependencies and stack have already been completed.
# This only implements copyfiles.
git "#{Chef::Config[:file_cache_path]}/dokku" do
  repository node['dokku']['git_repository']
  revision node['dokku']['git_revision']
  action node['dokku']['sync']['base'] ? :sync : :checkout
end

bash "dokku_copyfiles" do
  cwd "#{Chef::Config[:file_cache_path]}/dokku"
  code <<-EOH
    make copyfiles
  EOH
  only_if { node['dokku']['sync']['base'] }
end
