Standup.script do
  def run
    install_package 'postgresql-8.4 libpq-dev'
  
    upload script_file('postgresql.conf'),
           :to => '/etc/postgresql/8.4/main/postgresql.conf',
           :sudo => true
  
    tune_kernel
  
    sudo 'service postgresql-8.4 restart'
  end
  
  def tune_kernel
    sysctl_params = ['kernel.shmmax=134217728', 'kernel.shmall=2097152']
  
    remote_update '/etc/sysctl.conf',
                  sysctl_params.join("\n"),
                  :delimiter => '# standup script postgresql',
                  :sudo => true
  
    sysctl_params.each {|p| sudo "sysctl -w #{p}"}
  end
end
