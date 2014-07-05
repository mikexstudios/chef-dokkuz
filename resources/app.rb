actions :build, :release, :deploy, :delete

#default_action :fill_in

#TODO: Use regex matchers
attribute :app, :name_attribute => true, :required => true, :kind_of => String
