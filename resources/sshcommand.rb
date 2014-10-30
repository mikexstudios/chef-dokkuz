actions :create, :acl_add, :acl_remove

default_action :create

#TODO: Use regex matchers
attribute :user, :name_attribute => true, :required => true, :kind_of => String
attribute :command, :kind_of => String
attribute :identifier, :kind_of => String
# The ssh_pub_key may either be a string of the public key or a path to the
# public key.
attribute :ssh_pub_key, :kind_of => String
