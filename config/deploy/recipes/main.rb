namespace :deploy do

after "deploy:update", "deploy:cleanup"
after "deploy:finalize_update", "deploy:symlink_additional"

before "deploy", :roles => :web do
  deploy.setup
end

set :revision do
  git.list10
  default_ref = tags.split("\n").last
  ref = Capistrano::CLI.ui.ask "Branch/Tag to deploy: [default: last recent tag #{default_ref}] "
  ref = default_ref if ref.empty?
  ref
end

task :setup, :roles => :web do
  run "umask 02 && mkdir -p #{deploy_to} #{deploy_to}/releases #{resources_dir}"
  run "if [[ ! -d #{resources_dir}/#{drupal_folder_public} ]]; then mkdir #{resources_dir}/#{drupal_folder_public}; fi"
  run "if [[ ! -f #{resources_dir}/#{drupal_file_settings} ]]; then touch #{resources_dir}/#{drupal_file_settings}; fi"
  run "if [[ ! -d #{deploy_to}/#{temp_dir} ]]; then mkdir #{deploy_to}/#{temp_dir}; fi"
end

task :finalize_update do
  run "chmod -R g+w #{release_path};"
  run "mv #{release_path}/REVISION #{release_path}/REVISION.txt"
end

task :symlink_additional do
  if exists?(:z_additional_resources)
    z_additional_resources.each do |res|
      res.each {|k,v| run "ln -s #{k} #{v}" }
    end
  end
end

task :restart do
  # stub
end

end #namespace :deploy