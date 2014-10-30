node['dokku']['apps'].each do |app_name, config|
  #TODO: Compare defined apps with dokku images. Delete images/apps that 
  #are no longer defined.
  delete = !!config['remove']

  directory File.join(node['dokku']['root'], app_name) do
    owner 'dokku'
    group 'dokku'
    action delete ? :delete : :create
  end

  # Set environment variables (replaces config plugin)
  template File.join(node['dokku']['root'], app_name, 'ENV') do
    source 'apps/ENV.erb'
    owner  'dokku'
    group  'dokku'
    action :create
    variables(
      "env" => config['env'] || {}
    )
    not_if { delete }
  end

  # Clean up docker
  if delete
    docker_container "app/#{app_name}" do
      action :remove
    end

    docker_image "app/#{app_name}" do
      action :remove
    end
  end
end
