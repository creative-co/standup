Standup.script :node do
  self.description = 'Download Rails application database from node to local server'
  
  def run
    in_temp_dir do |dir|
      exec "#{scripts.webapp.db.dump_command scripts.webapp.db_name, 'webapp', 'webapp'} > dump.sql"
      local_exec "mkdir -p tmp/db"
      download "#{dir}/dump.sql",
               :to => 'tmp/db/dump.sql',
               :sudo => true
    end
    
    create_user 'webapp', 'webapp'
    create_database scripts.webapp.db_name, 'webapp'
    
    local_exec "#{scripts.webapp.db.load_command scripts.webapp.db_name, 'webapp', 'webapp'} < tmp/db/dump.sql"
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
  
  
  def exec_sql sql, db_name = 'mysql'
    local_exec "mysql -uroot -proot #{db_name} -e \"#{sql}\""
  end
end
