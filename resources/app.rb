actions :build, :release, :deploy, :cleanup

#default_action :fill_in

#TODO: Use regex matchers
attribute :app, :name_attribute => true, :required => true, :kind_of => String
