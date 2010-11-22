Standup.script :node do
  def run
    install_package 'mysql-server-5.1', :input => ['root', 'root', 'root']
    install_package 'libmysqlclient-dev'
    
    # todo: tune performance
  end
  
  def exec_sql sql
    exec "mysql -uroot -proot -e \"#{sql}\""
  end
  
  def create_user name, password
    if exec_sql("select user from mysql.user where user = '#{name}'").present?
      false
    else
      exec_sql "create user '#{name}'@'localhost' identified by '#{password}'"
      true
    end
  end
  
  def create_database name, owner
    if exec_sql("show databases like '#{name}'").present?
      false
    else
      exec_sql "create database #{name}"
      exec_sql "grant all on #{name}.* to '#{owner}'@'localhost'"
      true
    end
  end
  
  def dump_command database, username, password
    "mysqldump -u#{username} -p#{password} --compact -e --create-options --add-drop-table #{database}"
  end
  
  def load_command database, username, password
    "mysql -u#{username} -p#{password} #{database}"
  end
end
