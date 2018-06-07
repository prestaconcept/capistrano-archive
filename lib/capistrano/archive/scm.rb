require 'capistrano/scm/plugin'

module Capistrano
  module Archive
    class SCM < ::Capistrano::SCM::Plugin
      def set_defaults
        set_if_empty :archive_releases_path, ->{"./"}
        set_if_empty :archive_name, ->{"#{fetch(:application)}_#{fetch(:branch)}"}
        set_if_empty :archive_extension, ->{'tar.bz2'}
        set_if_empty :archive_tar_options, ->{'xjf'}
        set_if_empty :archive_workflow, ->{true}
        set_if_empty :archive_workflow_previous, ""
        set_if_empty :archive_workflow_next,->{"#{fetch(:stage)}"}
        set_if_empty :archive_remote_path, ->{"#{fetch(:tmp_dir)}"}
        set_if_empty :archive_revision, ->{true}
        set_if_empty :archive_revision_file, ->{'./REVISION'}
        set_if_empty :archive_revision_command, ->{'cat'}
        set_if_empty :archive_roles, ->{:all}
      end

      def define_tasks
        eval_rakefile File.expand_path('../tasks/archive.rake', __FILE__)
      end

      def register_hooks
        before 'deploy:new_release_path', 'archive:upload_archive'
        after "deploy:new_release_path", "archive:create_release"
        before "deploy:set_current_revision", "archive:set_current_revision"
        after 'deploy:finished', 'archive:copy_archive_file'
      end

      def release
        backend.execute :mkdir, '-p', release_path
        backend.execute(:tar, fetch(:archive_tar_options), uploaded_archive_filename, '-C', release_path)
      end

      # @return [String]
      def revision
        if fetch(:archive_revision)
          if File.file?(release_path_filename)
            `tar #{fetch(:archive_tar_options)} #{release_path_filename} --to-command=\'#{fetch(:archive_revision_command)}\' #{fetch(:archive_revision_file)}`.gsub(/\n/,"")
          else
            abort "Archive #{release_path_filename} doesn't exist!"
          end
        end
      end

      def check
        if !File.file?(release_path_filename)
          abort "Archive #{release_path_filename} doesn't exist!"
        end
      end

      # Upload archive file to server
      #
      # @return void
      def upload
        if File.file?(release_path_filename)
          backend.upload!(release_path_filename, fetch(:archive_remote_path))
        else
          abort "Archive #{release_path_filename} doesn't exist!"
        end
      end

      # Remove archive file
      #
      # @return void
      def clean
        backend.execute(:rm, '-f', uploaded_archive_filename)
      end

      # Copy archive file from previous stage to next stage directory release
      def copy
        if fetch(:archive_workflow)
          unless fetch(:archive_workflow_next).to_s.strip.empty?
            backend.execute(:cp, release_path_filename, "#{fetch(:archive_releases_path)}/#{fetch(:archive_workflow_next)}/")
          end
        end
      end

      # Path and filename to local archive
      #
      # @return [String]
      def release_path_filename
        @_release_path_filename ||= File.join(fetch(:archive_releases_path), fetch(:archive_workflow_previous) , release_filename)
      end

      # Filename to local archive
      #
      # @return [String]
      def release_filename
        @_release_filename ||= "#{fetch(:archive_name)}.#{fetch(:archive_extension)}"
      end

      # Archive uploaded filename
      #
      # @return [String]
      def uploaded_archive_filename
        @_uploaded_archive_filename ||= File.join(fetch(:archive_remote_path), release_filename)
      end

    end
 end
end
