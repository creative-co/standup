Standup.script do
  def run
    install_package 'monit'
    
    upload script_file('monitrc'),
           :to => '/etc/monit',
           :sudo => true
    upload script_file('monit'),
           :to => '/etc/default/monit',
           :sudo => true
    
    add_watch script_file('sshd.conf')
  end
  
  def add_watch file, name = File.basename(file), restart = true
    upload file,
           :to => "/etc/monit/conf.d/#{name}",
           :sudo => true
    
    sudo '/etc/init.d/monit restart' if restart
  end
  
  def restart_watch name
    sudo "monit restart #{name}"
  end
end
