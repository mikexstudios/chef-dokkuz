default['dokku']['pluginhook']['filename'] = 'pluginhook_0.1.0_amd64.deb'
default['dokku']['pluginhook']['src_url'] = 'https://s3.amazonaws.com/progrium-pluginhook/pluginhook_0.1.0_amd64.deb'

default['docker']['storage_driver'] = 'aufs' #aufs or devicemapper

default['dokku']['git_repository'] = 'https://github.com/progrium/dokku.git'
default['dokku']['git_revision'] = 'v0.2.3'

# Nginx settings for dokku
force_default['nginx']['default_site_enabled'] = false
force_default['nginx']['server_names_hash_bucket_size'] = 64

# Buildstep
default['dokku']['buildstep']['build_stack'] = false
default['dokku']['buildstep']['image_name'] = 'progrium/buildstep'
default['dokku']['buildstep']['stack_url'] = 'https://github.com/progrium/buildstep.git'
default['dokku']['buildstep']['stack_tag'] = '2014-03-08'
default['dokku']['buildstep']['prebuilt_url'] = 'https://github.com/progrium/buildstep/releases/download/2014-03-08/2014-03-08_429d4a9deb.tar.gz'
