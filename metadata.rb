name             'dokku'
maintainer       'Fabio Rehm'
maintainer_email 'fgrehm@gmail.com'
license          'MIT'
description      'Installs/Configures dokku'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.3'

supports 'ubuntu', '= 14.04'

# These cookbooks are so common that we do not version pin them.
%w{apt git build-essential user sudo ohai}.each do |dep|
  depends dep
end

depends 'docker', '~> 0.34.2'
depends 'nginx', '~> 2.7.4'
