include_recipe 'dokku::bootstrap'

include_recipe 'dokku::apps'

# Reload nginx
service 'nginx' do
  action :reload
end
