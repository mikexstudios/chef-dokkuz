# This recipe sets up example apps that will be deployed by the test script.
package 'curl' #required by kitchen test scripts

# Set up ssh key for deployment as 'root'
root_ssh_dir = '/root/.ssh'

## We need to create this directory first since the ssh-keygen command
## will cwd into here to supress interactive mode of ssh-keygen.
directory root_ssh_dir do
  owner 'root'
  group 'root'
  mode 0700
  action :create
end

execute "ssh-keygen -t rsa -N '' -f 'id_rsa'" do
  user 'root'
  group 'root'
  cwd root_ssh_dir 
  creates File.join(root_ssh_dir, 'id_rsa')
end

dokku_sshcommand "acl-remove root from user dokku" do
  action :acl_remove
  user 'dokku'
  identifier 'root'
end
dokku_sshcommand "acl-add root to user dokku" do
  action :acl_add
  user 'dokku'
  identifier 'root'
  ssh_pub_key '/root/.ssh/id_rsa.pub'
end
 
# Add localhost to known_hosts entry so that git push does not fail
ssh_known_hosts_entry 'localhost'


# Make sure original source is checked out
dokku_src = "#{Chef::Config[:file_cache_path]}/dokku"
git dokku_src do
  repository node['dokku']['git_repository']
  revision node['dokku']['git_revision']
  action :checkout
end
 
## Set root's git email and name to prevent warning message
bash 'test_helper_git_config_user' do
  code <<-EOH
    git config --global user.email 'root@example.com'
    git config --global user.name 'root'
  EOH
  user 'root'
  group 'root'
end

# Create a known test directory outside of the cache path
dokku_test_path = '/tmp/dokku-test'
dokku_test_apps_path = File.join(dokku_test_path, 'apps')
directory dokku_test_path do 
  action :delete
  recursive true
  owner 'root'
  group 'root'
end
directory dokku_test_apps_path do
  action :create
  recursive true
end


# For each test app, copy files and initialize as a git repository
Dir.glob("#{dokku_src}/tests/apps/*").each do |orig_app_path|
  app_name = File.basename(orig_app_path)
  app_path = File.join(dokku_test_apps_path, app_name)
  remote_app_name = "test-#{app_name}" #prevent conflict with existing apps
   
  # Only run test if the app is defined in our list of apps to test.
  next if not node['dokku']['test_deploy']['apps'].include? app_name and
          not node['dokku']['test_deploy']['apps'] == '*'
   
  # Copy the test app
  execute "cp -r #{orig_app_path} ." do
    user 'root'
    group 'root'
    cwd dokku_test_apps_path
  end
  
  # Clean up any old deployed test apps
  execute "dokku delete #{remote_app_name} || true" do
    user 'root'
  end
  
  bash "test_helper_gitadd_#{app_name}" do
    cwd app_path
    code <<-EOH
      git init
      git add .
      git commit -m 'initial commit'
      git remote add dokku dokku@localhost:#{remote_app_name}
    EOH
    user 'root'
    group 'root'
  end

  # Deploy app using dokku LWRPs.
  # NOTE: git push deploys are also tested, but actual deployment happens in
  #       deploy_apps.bats kitchen test script.
  # Clean up any old deployed test apps
  lwrp_app_name = "lwrp-#{app_name}"
  execute "dokku delete #{lwrp_app_name} || true" do
    user 'root'
  end
  dokku_app lwrp_app_name do
    action [:create, :build, :release, :deploy]
    source_path app_path
  end
end

# TODO: Remove the need to manually call cleanup.
dokku_dokku 'cleanup apps' do
  action :cleanup
end
