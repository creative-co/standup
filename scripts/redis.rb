Standup.script :node do
  REDIS_VERSION = "2.2.8"

  def run
    file_name = "redis-#{REDIS_VERSION}"

    #TODO check version, specify it in standup config file
    unless installed?
      in_temp_dir do
        exec "wget http://redis.googlecode.com/files/#{file_name}.tar.gz"
        exec "tar xvfz #{file_name}.tar.gz"
        exec "cd #{file_name} && sudo mkdir /opt/redis"
        exec "cd #{file_name} && sudo make PREFIX=/opt/redis install"
      end

      sudo "ln -s /opt/redis/bin/redis-server /usr/local/bin/redis-server"
      sudo "ln -s /opt/redis/bin/redis-cli /usr/local/bin/redis-cli"
    end

    with_processed_file script_file('redis.conf') do |file|
      upload file, :to => '/etc/redis.conf', :sudo => true
    end

    upload script_file('redis-server'), :to => '/etc/init.d/redis-server', :sudo => true

    sudo 'chmod +x /etc/init.d/redis-server'
    sudo '/usr/sbin/update-rc.d -f redis-server defaults'

    with_processed_file script_file('redis_monit.conf') do |file|
      scripts.monit.add_watch file
    end

    restart
  end

  def installed?
    sudo('find /usr/local/bin/redis-server').match(/No such file or directory/).blank?
  end
end