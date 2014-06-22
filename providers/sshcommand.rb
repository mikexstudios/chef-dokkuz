# Support whyrun
def whyrun_supported?
  true
end

action :create do
  converge_by("Create #{new_resource}") do
    execute "create user #{new_resource.user}" do
      # create will automatically check for existing account and is idempotent
      command "sshcommand create #{new_resource.user} #{new_resource.command}"
      user 'root'
    end
  end
end

action :acl_add do
  converge_by("ACL add #{new_resource}") do
    # Check if the ssh_pub_key is a string of the key or a path to the key
    # Need ::File to use ruby's File and not chef's File.
    key_cmd = ::File.exists?(new_resource.ssh_pub_key) ? 'cat' : 'echo'
    execute "acl-add #{new_resource.identifier} for user #{new_resource.user}" do
      # NOTE: This command is not idempotent.
      command "#{key_cmd} '#{new_resource.ssh_pub_key}' | sshcommand acl-add #{new_resource.user} #{new_resource.identifier}"
      user 'root'
    end
  end
end

action :acl_remove do
  converge_by("ACL remove #{new_resource}") do
    execute "acl-remove #{new_resource.identifier} for user #{new_resource.user}" do
      # NOTE: This command is not idempotent.
      command "sshcommand acl-remove #{new_resource.user} #{new_resource.identifier}"
      user 'root'
    end
  end
end
