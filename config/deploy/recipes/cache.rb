namespace :cache do



task :varnish, :roles => :web do

  varnishadm_pattern    = fetch(:varnishadm_pattern, "req.url ~ /")
  varnishadm_path       = fetch(:varnishadm_path , "/usr/bin/varnishadm")
  varnishadm_options    = fetch(:varnishadm_options , "-T 127.0.0.1:6082")

  run "#{varnishadm_path} #{varnishadm_options} ban \"#{varnishadm_pattern}\""

end #task varnish



task :opcache, :roles => :web do

  raise CommandError.new("Variable opcache_site_address not defined") unless exists?(:opcache_site_address)

  opcache_opcoder        = fetch(:opcache_opcoder, "apc")
  opcache_host_dest      = fetch(:opcache_host_dest, "127.0.0.1")
  opcache_utility        = fetch(:opcache_utility, "curl")
  opcache_utility_path   = fetch(:opcache_utility_path, "/usr/bin/#{opcache_utility}")
  opcache_filename_www   = fetch(:opcache_filename_www, "apc_clear.php")
  opcache_filename_admin = fetch(:opcache_filename_admin, "apc_clear_admin.php")
  z_opcache_path         = fetch(:z_opcache_path, "#{deploy_to}/#{current_dir}")

  randomstring  =  (("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a).to_a.shuffle.first(5).join

  case opcache_opcoder 
  when "apc"
    opcache_script_line = "<?php if ( $_SERVER['REMOTE_ADDR'] == '127.0.0.1' ) { apc_clear_cache(); apc_clear_cache('user'); apc_clear_cache('opcode'); echo json_encode(array('success' => true)); } ?>"
  when "opcache"
    opcache_script_line = "<?php if ( $_SERVER['REMOTE_ADDR'] == '127.0.0.1' ) { opcache_reset(); echo json_encode(array('success' => true)); } ?>"
  end

  put opcache_script_line, "#{z_opcache_path}/apc_clear.php"
  put opcache_script_line, "#{z_opcache_path}/apc_clear_admin.php"

  opcode_command = "#{opcache_utility_path} "

  case opcache_utility 
  when "wget"
    opcode_command = opcode_command + "-nv -O- --header 'Host: #{opcache_site_address}' "
    if exists?(:opcache_utility_user) && exists?(:opcache_utility_password)
      opcode_command = opcode_command + "--http-user='#{opcache_utility_user}' --http-password='#{opcache_utility_password}' "
    end
  when "curl"
    opcode_command = opcode_command + "-H 'Host:#{opcache_site_address}' "
    if exists?(:opcache_utility_user) && exists?(:opcache_utility_password)
      opcode_command = opcode_command + "--user #{opcache_utility_user}:#{opcache_utility_password} "
    end
  end

  opcode_command_www   = opcode_command + "'http://#{opcache_host_dest}/#{opcache_filename_www}?#{randomstring}'"
  opcode_command_admin = opcode_command + "'http://#{opcache_host_dest}/#{opcache_filename_admin}?#{randomstring}'"

  run "#{opcode_command_www}"
  run "#{opcode_command_admin}"

end #task opcache



end #namespace cache