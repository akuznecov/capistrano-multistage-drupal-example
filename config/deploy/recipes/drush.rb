namespace :drush do

current_docroot_dir = fetch(:current_docroot_dir, "#{deploy_to}/#{current_dir}")
drush_path          = fetch(:drush_path, "/usr/bin/drush")

task :cc, :roles => :web do
  run "#{drush_path} cc all -r #{current_docroot_dir}", :once => true
end #cc


task :updatedb, :roles => :web do
  run "#{drush_path} -y updatedb -r #{current_docroot_dir}", :once => true
end #updatedb


task :fra, :roles => :web do
  run "#{drush_path} -y fra -r #{current_docroot_dir}", :once => true
end #fra


task :siteupdate, :roles => :web do
  drush.updatedb
  drush.cc
  drush.fra
  drush.cc
end #siteupdate


task :siteupdate_each_subsite, :roles => :web do
  list_sites = capture("find #{current_docroot_dir}/sites -maxdepth 1 -mindepth 1 -type d | egrep -v '(default|all)'")
  list_drush_commands = ["-y updatedb", "cc all", "-y fra", "cc all"]
  list_sites.split.each do |site|
    list_drush_commands.each do |drush_commmand|
      run "#{drush_path} #{drush_commmand} -r #{current_docroot_dir} -l http://#{site.gsub("#{current_docroot_dir}/sites/", '')}", :once => true
    end
  end
end #siteupdate_each_subsite


task :enable, :roles => :web, :except => { :no_release => true } do
  run "#{drush_path} -r #{current_docroot_dir} vset --yes maintenance_mode 0", :once => true
end #enable


task :disable, :roles => :web, :except => { :no_release => true } do
  run "#{drush_path} -r #{current_docroot_dir} vset --yes maintenance_mode 1", :once => true
end #disable


task :cron_enable, :roles => :web, :except => { :no_release => true } do
  run "#{drush_path} -r #{deploy_to}/#{current_dir} vset --yes elysia_cron_disabled 0", :once => true
end #cron_enable


task :cron_disable, :roles => :web, :except => { :no_release => true } do
  run "#{drush_path} -r #{deploy_to}/#{current_dir} vset --yes elysia_cron_disabled 1 ", :once => true
end #cron_disable


end # namespace
