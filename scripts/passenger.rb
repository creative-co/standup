Standup.script do
  def run
    scripts.ec2.open_port 80
    
    install_gem 'passenger', '3.0.0'
    
    unless file_exists? '/opt/nginx/sbin/nginx'
      install_package 'libcurl4-openssl-dev'
      sudo 'passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx'
    end
    
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
  
  def restart_nginx
    scripts.monit.restart_watch 'nginx'
  end
end