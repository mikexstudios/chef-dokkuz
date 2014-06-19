# The idea of this recipe is to deploy the test apps included with dokku,
# check that they exhibit the correct output, and delete the app.

dokku_src = "#{Chef::Config[:file_cache_path]}/dokku-test"
# We delete the src directory because the test apps have been modified with
# git init.
directory dokku_src do
  action :delete
  recursive true
end
git dokku_src do
  repository node['dokku']['git_repository']
  revision node['dokku']['git_revision']
  action :checkout
end

test_dir = "#{dokku_src}/tests/apps"

 
# Set up ssh key for deployment
root_ssh_dir = '/root/.ssh'
directory root_ssh_dir do
  owner 'root'
  group 'root'
  mode 0700
  action :create
end

bash 'test_deploy_generate_ssh_key' do
  user 'root'
  group 'root'
  cwd root_ssh_dir 
  code <<-EOH
    ssh-keygen -t rsa -N '' -f 'id_rsa'
  EOH
  not_if { File.exists? File.join(root_ssh_dir, 'id_rsa') }
end

# TODO: Make this a LWRP
bash 'test_deploy_set_ssh_key' do
  user 'root'
  group 'root'
  cwd '/root'
  code <<-EOH
    cat ~/.ssh/id_rsa.pub | sshcommand acl-add dokku progrium
  EOH
end

# Set root's git email and name to prevent warning message
bash 'test_deploy_git_config_user' do
  code <<-EOH
    git config --global user.email 'root@example.com'
    git config --global user.name 'root'
  EOH
  user 'root'
  group 'root'
end

# Add localhost to known_hosts entry so that git push does not fail
ssh_known_hosts_entry 'localhost'

# git init and push each of the test apps
Dir.glob("#{test_dir}/*").each do |app_path|
  app_name = File.basename(app_path)
  remote_app_name = "test-#{app_name}" #prevent conflict with existing apps

  # Only run test if the app is defined in our list of apps to test.
  next if not node['dokku']['test_deploy']['apps'].include? app_name and
          not node['dokku']['test_deploy']['apps'] == '*'

  # Delete remote git repository if already exist. This may occur if a previous
  # app push failed.
  directory File.join(node['dokku']['root'], remote_app_name) do
    action :delete
    recursive true
  end

  bash "test_deploy_push_app_#{app_name}" do
    cwd File.join(test_dir, app_name)
    code <<-EOH
      git init
      git add .
      git commit -m 'initial commit'
      git remote add dokku dokku@localhost:#{remote_app_name}
      git push dokku master
    EOH
    user 'root'
    group 'root'
  end

  # Get the url of app
  # We place it inside of a ruby_block so that this command is run after the
  # above bash command completes.
  # NOTE: The problem is that app_url variable does not persist outside of
  # the ruby_block, so it is difficult to do further testing to verify that
  # the app is deployed correctly.
  ruby_block "get_app_url_#{app_name}" do
    block do
      app_url = `dokku url #{remote_app_name}`
      puts "App URL: #{app_url}"
    end
  end

  # Delete app
  # TODO: Make this a LWRP
  bash "test_deploy_delete_app_#{app_name}" do
    code <<-EOH
      dokku delete #{remote_app_name}
    EOH
    user 'root'
    group 'root'
  end
end
