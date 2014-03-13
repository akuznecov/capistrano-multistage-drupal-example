role :web, "192.168.0.1"
role :web, "192.168.0.2"

set :repository, "git@git.adyax.com:application"
set :branch, "master"

set :drush_path, "/opt/drush/drush"

set :user, "app-user"

set :deploy_to, "/var/www/application"
set :resources_dir, "/var/www/application/resources"
set :copy_remote_dir, "#{deploy_to}/#{temp_dir}"

set :varnishadm_path, "varnishadm -T 127.0.0.1:6082"

set :z_additional_resources, [ { "#{resources_dir}/#{drupal_folder_public}" => "#{release_path}/sites/default/#{drupal_folder_public}" }, { "#{resources_dir}/#{drupal_file_settings}" => "#{release_path}/sites/default/#{drupal_file_settings}" } ]

set :apc_site_address, "example.com"
set :apc_utility, "wget"
set :apc_utility_path, "/usr/bin/wget"
