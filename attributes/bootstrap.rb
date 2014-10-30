default['dokku']['sshcommand']['src_url'] = 'https://raw.github.com/progrium/sshcommand/master/sshcommand'

default['dokku']['pluginhook']['filename'] = 'pluginhook_0.1.0_amd64.deb'
default['dokku']['pluginhook']['src_url'] = 'https://s3.amazonaws.com/progrium-pluginhook/pluginhook_0.1.0_amd64.deb'

default['docker']['storage_driver'] = 'aufs' #aufs or devicemapper

default['dokku']['git_repository'] = 'https://github.com/progrium/dokku.git'
default['dokku']['git_revision'] = 'v0.2.3'

# Nginx settings for dokku
force_default['nginx']['default_site_enabled'] = false
force_default['nginx']['server_names_hash_bucket_size'] = 64
