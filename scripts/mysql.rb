Standup.script :node do
  def run
    install_package 'mysql-server-5.1', :input => ['root', 'root', 'root']
    install_package 'libmysqlclient-dev'
    
    # todo: tune performance
  end
  
  def exec_sql sql, local = false
    command = "mysql -uroot -proot -e \"#{sql}\""
    if local
      local_exec command
    else
      exec command
    end
  end
  
  def create_database name, local = false
    if exec_sql("show databases like '#{name}'", local).present?
      false
    else
      exec_sql "create database #{name}", local
      true
    end
  end
  
  def dump_command database, username = 'root', password = 'root'
    "mysqldump -u#{username} -p#{password} --compact -e --create-options --add-drop-table #{database}"
  end
  
  def load_command database, username = 'root', password = 'root'
    username = 'root' if username == :local
    "mysql -u#{username} -p#{password} #{database}"
  end
end
