namespace :cache do

task :varnish, :roles => :web do
  run "#{varnishadm_path} ban \"req.url ~ /\""
end

task :drush, :roles => :web do
  run "#{drush_path} cc all -r #{deploy_to}/#{current_dir};", :once => true
end

task :apc, :roles => :web do
  apc_script_line = "<?php if ( $_SERVER['REMOTE_ADDR'] == '127.0.0.1' ) { apc_clear_cache(); apc_clear_cache('user'); apc_clear_cache('opcode'); echo json_encode(array('success' => true)); } ?>"
  put apc_script_line, "#{z_apc_path}/apc_clear.php"
  put apc_script_line, "#{z_apc_path}/apc_clear_admin.php"
  o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
  randomstring  =  (0...5).map{ o[rand(o.length)] }.join

  # wget
  if exists?(:apc_utility) and apc_utility == "wget"
  	if exists?(:apc_utility_user) && exists?(:apc_utility_password)
		run "#{apc_utility_path} -nv -O- --header 'Host: #{apc_site_address}' --http-user='#{apc_utility_user}' --http-password='#{apc_utility_password}' 'http://localhost/apc_clear.php?#{randomstring}'"
		run "#{apc_utility_path} -nv -O- --header 'Host: #{apc_site_address}' --http-user='#{apc_utility_user}' --http-password='#{apc_utility_password}' 'http://localhost/apc_clear_admin.php?#{randomstring}'"
	else
		run "#{apc_utility_path} -nv -O- --header 'Host: #{apc_site_address}' 'http://localhost/apc_clear.php?#{randomstring}'"
		run "#{apc_utility_path} -nv -O- --header 'Host: #{apc_site_address}' 'http://localhost/apc_clear_admin.php?#{randomstring}'"
	end

  # curl
  elsif exists?(:apc_utility) and apc_utility == "curl"
	if exists?(:apc_utility_user) && exists?(:apc_utility_password)
		run "#{apc_utility_path} --user #{apc_utility_user}:#{apc_utility_password} -H 'Host:#{apc_site_address}' 'http://localhost/apc_clear.php?#{randomstring}'"
		run "#{apc_utility_path} --user #{apc_utility_user}:#{apc_utility_password} -H 'Host:#{apc_site_address}' 'http://localhost/apc_clear_admin.php?#{randomstring}'"
	else
		run "#{apc_utility_path} -H 'Host:#{apc_site_address}' 'http://localhost/apc_clear.php?#{randomstring}'"
		run "#{apc_utility_path} -H 'Host:#{apc_site_address}' 'http://localhost/apc_clear_admin.php?#{randomstring}'"
	end
  end
end

end
