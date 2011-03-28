Standup.script :node do
  def run
    install_packages 'python-software-properties'
    sudo 'add-apt-repository ppa:pitti/postgresql'
    sudo 'apt-get update'

    #TODO execute sql /usr/share/postgresql/9.0/contrib/adminpack.sql
    install_packages 'postgresql postgresql-contrib libpq-dev'

    upload script_file('pg_hba.conf'),
           :to => '/etc/postgresql/9.0/main/pg_hba.conf',
           :sudo => true
  
    upload script_file('postgresql.conf'),
           :to => '/etc/postgresql/9.0/main/postgresql.conf',
           :sudo => true
  
    tune_kernel
  
    sudo 'service postgresql restart'
  end

  def exec_sql sql, local = false
    command = "psql -c \"#{sql}\" -U postgres -w"
    if local
      local_exec command
    else
      exec command
    end
  end
  
  def create_database name, local = false
    if exec_sql("select * from pg_database where datname = '#{name}'", local) =~ /1 row/
      false
    else
      exec_sql "create database #{name}", local
      true
    end
  end
  
  def dump_command database, username = 'postgres', *args
    "pg_dump -c #{database} -U #{username} -w"
  end
  
  def load_command database, username = 'postgres', *args
    "psql #{database} -U #{username} -w"
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
