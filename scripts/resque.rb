Standup.script :node do
  def run
    scripts.redis.install_from_resque if  sudo('find /etc/init.d/redis-server').match(/No such file or directory/).present?

    path_to_resque_exec = "#{scripts.webapp.app_path}/script/resque"
    with_processed_file script_file('resque') do |file|
      upload file,
             :to => path_to_resque_exec,
             :sudo => true
    end

    sudo "chown www-data:www-data #{path_to_resque_exec}"
    sudo "chmod +x #{path_to_resque_exec}"

    sudo "mkdir #{scripts.webapp.app_path}/tmp/pids"
    sudo "chown www-data:www-data #{scripts.webapp.app_path}/tmp/pids"
    with_processed_file script_file('resque_monit.conf') do |file|
      scripts.monit.add_watch file
    end

    restart
  end

  def restart
    ((scripts.webapp.params.has_key?(:resque_queues) && scripts.webapp.params.resque_queues.presence) || {"ALL_QUEUES" => 1 }).each_pair do |queue_name, num_of_workers|
      1.upto(num_of_workers)  do |num|
        scripts.monit.restart_watch "resque_#{queue_name}_#{num}"
      end
     end
  end
end