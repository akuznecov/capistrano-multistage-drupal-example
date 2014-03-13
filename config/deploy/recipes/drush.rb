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

end