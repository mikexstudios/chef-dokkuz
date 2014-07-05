# Support whyrun
def whyrun_supported?
  true
end

action :build do
  converge_by("Build #{new_resource}") do
    execute "build app #{new_resource.app}" do
      cwd File.join(node['dokku']['root'], new_resource.app)
      command "git archive master | dokku build #{new_resource.app}"
      user 'dokku'
    end
  end
end

action :release do
  converge_by("Release #{new_resource}") do
    execute "release app #{new_resource.app}" do
      command "dokku release #{new_resource.app}"
      user 'dokku'
    end
  end
end

action :deploy do
  converge_by("Deploy #{new_resource}") do
    execute "deploy app #{new_resource.app}" do
      command "git archive master | dokku build #{new_resource.app}"
      user 'dokku'
    end
  end
end

#TODO: Move this into an app or deploy provider while non-app specific actions
#(like cleanup) are placed into a separate file.

#action :acl_add do
#  converge_by("ACL add #{new_resource}") do
#    # Check if the ssh_pub_key is a string of the key or a path to the key
#    # Need ::File to use ruby's File and not chef's File.
#    key_cmd = ::File.exists?(new_resource.ssh_pub_key) ? 'cat' : 'echo'
#    execute "acl-add #{new_resource.identifier} for user #{new_resource.user}" do
#      # NOTE: This command is not idempotent.
#      command "#{key_cmd} '#{new_resource.ssh_pub_key}' | sshcommand acl-add #{new_resource.user} #{new_resource.identifier}"
#      user 'root'
#    end
#  end
#end
#
#action :acl_remove do
#  converge_by("ACL remove #{new_resource}") do
#    execute "acl-remove #{new_resource.identifier} for user #{new_resource.user}" do
#      # NOTE: This command is not idempotent.
#      command "sshcommand acl-remove #{new_resource.user} #{new_resource.identifier}"
#      user 'root'
#    end
#  end
#end
