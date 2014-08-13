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

task :cleanup, :except => { :no_release => true } do
  count = fetch(:keep_releases, 5).to_i
  local_releases = capture("ls -xt #{releases_path}").split.reverse
  if count >= local_releases.length
    logger.important "no old releases to clean up"
  else
    logger.info "keeping #{count} of #{local_releases.length} deployed releases"
    directories = (local_releases - local_releases.last(count)).map { |release|
    File.join(releases_path, release) }.join(" ")
    directories.split(' ').each do | oldreleasedir |
      tmpreleasedir = oldreleasedir.chomp
      drupal_root = capture("find #{tmpreleasedir} -maxdepth 2 -true -type f -name install.php | xargs -I {} dirname {}").gsub(/\r\n$/, "")
      drupal_root_processed = tmpreleasedir + drupal_root.split(tmpreleasedir).last.to_s
      run "if [[ -d #{drupal_root_processed}/sites/ ]]; then chmod u+w #{drupal_root_processed}/sites/*; find #{drupal_root_processed}/sites/ -maxdepth 2 -type f -name settings.php -print0 | xargs -I{} -0 chmod u+w {}; fi"
    end
    run "rm -rf #{directories}"
  end
end

task :restart do
  # stub
end

end #namespace :deploy