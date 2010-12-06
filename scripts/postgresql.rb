Standup.script :node do
  def run
    install_packages 'postgresql-8.4 libpq-dev'
  
    upload script_file('postgresql.conf'),
           :to => '/etc/postgresql/8.4/main/postgresql.conf',
           :sudo => true
  
    tune_kernel
  
    sudo 'service postgresql-8.4 restart'
  end
  
  def exec_sql sql
    su_exec 'postgres', "psql -c \"#{sql}\""
  end
  
  def create_user name, password
    if exec_sql("select * from pg_user where usename = '#{name}'") =~ /1 row/
      false
    else
      exec_sql "create user #{name} with password '#{password}'"
      true
    end
  end
  
  def create_database name, owner
    if exec_sql("select * from pg_database where datname = '#{name}'") =~ /1 row/
      false
    else
      exec_sql "create database #{name} with owner #{owner}"
      true
    end
  end
  
  def dump_command database, username = 'postgres', *args
    "sudo su -c \"pg_dump -c #{database}\" #{username}"
  end
  
  def load_command database, username = 'postgres', *args
    if username == :local
      "psql #{database}"
    else
      "sudo su -c \"psql #{database}\" #{username}"
    end
  end
  
  protected
  
  def tune_kernel
    sysctl_params = ['kernel.shmmax=134217728', 'kernel.shmall=2097152']
  
    remote_update '/etc/sysctl.conf',
                  sysctl_params.join("\n"),
                  :delimiter => '# standup script postgresql',
                  :sudo => true
  
    sysctl_params.each {|p| sudo "sysctl -w #{p}"}
  end
end
