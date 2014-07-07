actions :create, :build, :release, :deploy, :delete, :run

default_action [:create, :build, :release, :deploy]

#TODO: Use regex matchers
attribute :app, :name_attribute => true, :required => true, :kind_of => String

# For :build action
attribute :source_path, :kind_of => String
 
# For :run action
attribute :command, :kind_of => String
