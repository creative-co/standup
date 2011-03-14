Standup.script :node do
  def run
    raise "Please call resque install instead"
  end

  def install_from_resque
    in_dir scripts.webapp.app_path do
      sudo "rake redis:install"
    end

    upload script_file('redis.conf'),
           :to => '/etc/redis.conf',
           :sudo => true
    with_processed_file script_file('redis.conf') do |file|
      upload file, :to => '/etc/redis.conf',
             :sudo => true
    end
    upload script_file('redis-server'),
           :to => '/etc/init.d/redis-server',
           :sudo => true

    sudo 'chmod +x /etc/init.d/redis-server'
    sudo '/usr/sbin/update-rc.d -f redis-server defaults'
    sudo 'service redis-server stop'
    sudo 'service redis-server start'

    with_processed_file script_file('redis_monit.conf') do |file|
      scripts.monit.add_watch file
    end

    restart
  end

  def restart
    scripts.monit.restart_watch 'redis'
  end
end