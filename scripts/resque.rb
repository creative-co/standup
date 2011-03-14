Standup.script :node do
  def run
    scripts.redis.install_from_resque unless File.exists?("/etc/init.d/redis-server")

    path_to_resque_exec = "#{scripts.webapp.app_path}/script/resque"
    upload script_file('resque'),
           :to => path_to_resque_exec,
           :sudo => true
    sudo "chown www-data:www-data #{path_to_resque_exec}"
    sudo "chmod +x #{path_to_resque_exec}"

    sudo "mkdir #{scripts.webapp.app_path}/tmp/pids"
    with_processed_file script_file('resque_monit.conf') do |file|
      scripts.monit.add_watch file
    end

    restart
  end

  def restart
    scripts.monit.restart_watch 'resque'
  end
end