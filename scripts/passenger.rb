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
    
    upload script_file('upstart.conf'),
           :to =>'/etc/init/nginx.conf',
           :sudo => true
    sudo 'initctl reload-configuration'
    
    restart_nginx
  end
  
  def restart_nginx
    if exec('initctl status nginx') =~ /running/i
      sudo 'initctl restart nginx'
    else
      sudo 'initctl start nginx'
    end
  end
end