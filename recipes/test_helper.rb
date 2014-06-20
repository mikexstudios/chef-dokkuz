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

bash 'test_helper_set_sshcommand' do
  user 'root'
  group 'root'
  code <<-EOH
    sshcommand acl-remove dokku root
    cat /root/.ssh/id_rsa.pub | sshcommand acl-add dokku root
  EOH
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

# Create a known test directory outside of the cache path
dokku_test_path = '/tmp/dokku-test'
directory dokku_test_path do 
  action :delete
  recursive true
  owner 'root'
  group 'root'
end
directory dokku_test_path do
  action :create
end

# Copy the test apps 
execute "cp -r #{File.join(dokku_src, 'tests/apps')} ." do
  user 'root'
  group 'root'
  cwd dokku_test_path
end


# For each test app, initialize as a git repository

## Set root's git email and name to prevent warning message
bash 'test_helper_git_config_user' do
  code <<-EOH
    git config --global user.email 'root@example.com'
    git config --global user.name 'root'
  EOH
  user 'root'
  group 'root'
end

Dir.glob("#{dokku_test_path}/apps/*").each do |app_path|
  app_name = File.basename(app_path)
  remote_app_name = "test-#{app_name}" #prevent conflict with existing apps
  
  # Clean up any old deployed test apps
  execute "dokku delete #{remote_app_name} || true" do
    user 'root'
    group 'root'
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
end
