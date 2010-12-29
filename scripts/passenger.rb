Standup.script :node do
  def run
    scripts.ec2.open_port 80, 443
    
    if install_gem('passenger', '3.0.1') || !file_exists?('/opt/nginx/sbin/nginx')
      install_package 'libcurl4-openssl-dev'
      sudo 'passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx'
    end
    
    sudo 'mkdir -p /opt/nginx/conf/servers'
    
    upload script_file('nginx.conf'),
           :to =>'/opt/nginx/conf/nginx.conf',
           :sudo => true
    
    upload script_file('nginx'),
           :to =>'/etc/init.d/nginx',
           :sudo => true
    
    sudo 'chmod +x /etc/init.d/nginx'
    sudo '/usr/sbin/update-rc.d -f nginx defaults'
    
    scripts.monit.add_watch script_file('nginx_monit.conf')
    
    restart_nginx
  end
  
  def add_server_conf file, name = File.basename(file), restart = true
    upload file,
           :to   => "/opt/nginx/conf/servers/#{name}",
           :sudo => true
    
    restart_nginx if restart
  end
  
  def restart_nginx
    scripts.monit.restart_watch 'nginx'
  end
end