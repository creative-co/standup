Standup.script :node do
  self.description = 'Download Rails application database from node to local server'
  
  def run
    in_temp_dir do |dir|
      exec 'chmod 777 .'
      su_exec 'postgres', "pg_dump -c #{scripts.webapp.db_name} > dump.sql"
      local_exec "mkdir -p tmp/db"
      download "#{dir}/dump.sql",
               :to => 'tmp/db/dump.sql',
               :sudo => true
    end
    
    bootstrap_db
    
    local_exec "psql #{scripts.webapp.db_name} < tmp/db/dump.sql"
  end
  
  def bootstrap_db
    unless exec_sql("select * from pg_user where usename = 'webapp'") =~ /1 row/
      exec_sql "create user webapp with password 'webapp'"
    end
    
    unless exec_sql("select * from pg_database where datname = '#{scripts.webapp.db_name}'") =~ /1 row/
      exec_sql "create database #{scripts.webapp.db_name} with owner webapp"
    end
  end
  
  def exec_sql sql, db_name = 'postgres'
    local_exec "psql #{db_name} -c \"#{sql}\""
  end
end
