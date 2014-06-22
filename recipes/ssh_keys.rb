node['dokku']['ssh_keys'].each do |username, key|
  dokku_sshcommand "acl-add #{username} to user dokku" do
    action :acl_add
    user 'dokku'
    identifier username
    ssh_pub_key key
  end
end
