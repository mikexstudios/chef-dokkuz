# Support whyrun
def whyrun_supported?
  true
end

action :create do
  converge_by("Create #{new_resource}") do
    directory ::File.join(node['dokku']['root'], new_resource.app) do
      action :create
      owner 'dokku'
      group 'dokku'
    end
    directory ::File.join(node['dokku']['root'], new_resource.app, 'cache') do
      action :create
      owner 'dokku'
      group 'dokku'
    end
  end
end

action :build do
  converge_by("Build #{new_resource}") do
    execute "build app #{new_resource.app}" do
      cwd new_resource.source_path
      command "tar cC . . | dokku build #{new_resource.app}"
      user 'root' #can't run as 'dokku' user since interacts with docker
    end
  end
end

action :release do
  converge_by("Release #{new_resource}") do
    execute "release app #{new_resource.app}" do
      command "dokku release #{new_resource.app}"
      user 'root'
    end
  end
end

action :deploy do
  converge_by("Deploy #{new_resource}") do
    execute "deploy app #{new_resource.app}" do
      command "dokku deploy #{new_resource.app}"
      user 'root'
    end
  end
end

action :delete do
  converge_by("Delete #{new_resource}") do
    execute "delete app #{new_resource.app}" do
      command "dokku delete #{new_resource.app}; dokku cleanup"
      user 'root'
    end
  end
end
