set :stages, ["stage", "preprod", "prod"]
set :default_stage, "stage"
require 'capistrano/ext/multistage'

set :application, "example"

set :copy_exclude, [".project", ".git", ".gitignore", "nbproject", "html", "CHANGELOG.txt", "COPYRIGHT.txt", "INSTALL.mysql.txt", "INSTALL.pgsql.txt", "INSTALL.sqlite.txt", "INSTALL.txt", "LICENSE.txt", "MAINTAINERS.txt", "README.txt", "UPGRADE.txt", "web.config"]
set :current_dir, "current"

set :deploy_via, :copy
set :drupal_file_settings, "settings.php"
set :drupal_folder_private, "private"
set :drupal_folder_public, "files"
set :git_enable_submodules, false
set :keep_releases, "10"
set :scm, "git"
set :scm_password, "none"
set :scm_username, "git"
set :synchronous_connect, true
set :temp_dir, "tmp"
set :temp_folder, "/tmp"
set :use_sudo, false

set :ssh_options, { :forward_agent => true, :auth_methods => [%{publickey}] }
default_run_options[:pty] = true
default_run_options[:shell] = '/bin/bash'

Dir['config/deploy/recipes/*.rb'].each { |recipe| load(recipe) }
