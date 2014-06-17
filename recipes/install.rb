include_recipe 'dokku::bootstrap'

include_recipe 'dokku::apps'

include_recipe 'dokku::ssh_keys'

# Reload nginx
service 'nginx' do
  action :reload
end
