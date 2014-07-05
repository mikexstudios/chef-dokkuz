# Support whyrun
def whyrun_supported?
  true
end

action :cleanup do
  converge_by ('Cleanup apps') do
    execute 'cleanup apps' do
      command 'dokku cleanup'
      user 'dokku'
    end
  end
end
