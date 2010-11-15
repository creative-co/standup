Standup.script :node do
  self.description = 'Upload Rails application database from local server to node'
  
  def run
    local_exec "mkdir -p tmp/db"
    local_exec "pg_dump -c #{scripts.webapp.db_name} > tmp/db/dump.sql"
    
    in_temp_dir do |dir|
      upload 'tmp/db/dump.sql',
             :to => "#{dir}/dump.sql"
      exec "chmod 777 #{dir}/dump.sql"
      
      su_exec 'postgres', "psql #{scripts.webapp.db_name} < #{dir}/dump.sql"
    end
  end
end
