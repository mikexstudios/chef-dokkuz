actions :create, :build, :release, :deploy, :delete

default_action [:create, :build, :release, :deploy]

#TODO: Use regex matchers
attribute :app, :name_attribute => true, :required => true, :kind_of => String
attribute :source_path, :kind_of => String #for :build action
