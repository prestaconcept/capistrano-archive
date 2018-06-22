# capistrano-archive

[![Gem Version](https://badge.fury.io/rb/capistrano-archive.svg)](https://badge.fury.io/rb/capistrano-archive)

This plugin adds a new scm to Capistrano 3 allowing deployment from an archive stored on the target server (s).

## Features

 * Upload an archive (tar.bz2 as default) to target
 * Create release from the archive
 * Can use a file from the archive to know the deployed revision (./REVISION as default) 
 * Workflow between deploy stages copying the local archive on stage directory 

## Installation

Put this in the Gemfile
```
    gem 'capistrano-archive'
```

Then run 
```    
    bundle install
```

Add theses lines to your Capfile

```ruby
# Include and use capistrano archive 
require "capistrano/archive"
install_plugin Capistrano::Archive::SCM
```

## Usage

First, you need to have a build system storing artefact release on the server used to deploy.

### Archive location and name

To specify the archive location, you can set the `:archive_release_path` variable. As default, the archive is supposed to be stored in the current directory.

The archive name is built as `:application_:branch` but you can change that with the `:archive_name` variable.  

### Compression

The tar is compressed with bzip as default but you can change that with `:archive_extension` and `:archive_tar_options` variables.

### Upload

As default the archive is sent in the `:tmp_dir` but you can change the destination using the `:archive_remote_path` variable.

If you have multiple servers in same stage, you can upload the archive on some servers only using the `:archive_roles` variable.

Using a shared storage for theses servers, you can upload the archive one time only in a shared location and use it on each server. For example like that :

```
  set :archive_roles, :upload
  set :archive_remote_path, "/nas/..."
```

### Workflow

If you want have workflow between stage, like force deploy on staging before production, you can set the  `:archive_workflow_previous` variable in your stages config file.

For example, in a *staging.rb* file, set the variable like that

```ruby 
  set :archive_workflow_previous, "build"  
```

And the archive location will be `:archive_releases_path`/build when you deploy the staging stage.
After the deploy, the archive file will be copied in the `:archive_workflow_next`, as default the current stage.

Do the same in a *production.rb* file

```ruby 
  set :archive_workflow_previous, "staging"
```

And the archive location will be `:archive_releases_path`/staging when you deploy the production stage. 
So you'll have to deploy on staging before production. 

If you want turn off the workflow process, set the variable `:archive_workflow` to false.

### Revision

Capistrano log the revision info, the sha1 commit, in the revisions log file and in the file REVISION.
Since we are deploying from an archive, if we want to have the same info, it must already be present in the archive.
The most easy is to store the commit when build the archive in the REVISION file.

As default, the plugin can read the REVISION file from the archive.

If you want to store the info in another file, you can set the file with the `:archive_revision_file` variable.
If you have to manipulate the output (grep, awk, etc) you can change the `:archive_revision_command`

If you want turn off the revision process, set the variable `:archive_revision` to false. 

### Variables available

If you need to change default values, you can set the following configuration variables in `config/deploy.rb` or wherever relevant:

```ruby
  set :archive_releases_path, "./"
  set :archive_name, "#{fetch(:application)}_#{fetch(:branch)}"
  set :archive_extension, 'tar.bz2'
  set :archive_tar_options, 'xjf'
  set :archive_workflow, true
  set :archive_workflow_previous, ""
  set :archive_workflow_next,"#{fetch(:stage)}"
  set :archive_remote_path, "#{fetch(:tmp_dir)}"
  set :archive_revision, true
  set :archive_revision_file, './REVISION'
  set :archive_revision_command, 'cat'
```

## Contributing

Please feel free to open an [issue](https://github.com/prestaconcept/capistrano-archive/issues) 
or a [pull request](https://github.com/prestaconcept/capistrano-archive), 
if you want to help.

Thanks to
[everyone who has contributed](https://github.com/prestaconcept/capistrano-archive/graphs/contributors) already.

---

*This project is supported by [PrestaConcept](http://www.prestaconcept.net)*

Released under the [MIT License](LICENSE)