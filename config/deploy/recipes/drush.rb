namespace :drush do

task :updatedb, :roles => :web do
  run "#{drush_path} -y updatedb -r #{deploy_to}/#{current_dir}", :once => true
end

task :fra, :roles => :web do
  run "#{drush_path} -y fra -r #{deploy_to}/#{current_dir}", :once => true
end

task :siteupdate, :roles => :web do
  drush.updatedb
  cache.drush
  drush.fra
  cache.drush
end

task :enable, :roles => :web, :except => { :no_release => true } do
    run "#{drush_path} -r #{deploy_to}/#{current_dir} vset --yes maintenance_mode 0", :once => true
end

task :disable, :roles => :web, :except => { :no_release => true } do
    run "#{drush_path} -r #{deploy_to}/#{current_dir} vset --yes maintenance_mode 1", :once => true
end

end