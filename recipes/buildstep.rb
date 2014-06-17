# Install stack using buildstep
if node['dokku']['buildstep']['build_stack']
  docker_image node['dokku']['buildstep']['image_name'] do
    source node['dokku']['buildstep']['stack_url']
    action :build
  end
else
  docker_image node['dokku']['buildstep']['image_name'] do
    source node['dokku']['buildstep']['prebuilt_url']
    action :import
  end
end

# TODO: Custom buildpacks (?)
