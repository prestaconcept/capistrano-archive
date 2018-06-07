set :archive_plugin, self

namespace :archive do
  desc 'Check that the archive is readable'
  task :check do
    run_locally do
      fetch(:archive_plugin).check
    end
  end 
 
  desc 'Upload release to current stage'
  task :upload_archive do
    on release_roles(fetch(:archive_roles)) do
        fetch(:archive_plugin).upload
    end
  end
 
  desc 'Copy repo to releases'
  task :create_release do
    on release_roles :all do
      fetch(:archive_plugin).release
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
      set :current_revision, fetch(:archive_plugin).revision
  end
  
  desc 'Clean : remove archive file after deploy'
  task :clean do
    on roles(:app) do
      fetch(:archive_plugin).clean
    end
  end
  
  desc 'Copy local archive to make it available to next stage'
  task :copy_archive_file do
    run_locally do
      fetch(:archive_plugin).copy
    end
  end

end
