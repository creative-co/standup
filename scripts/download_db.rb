Standup.script :node do
  self.description = 'Download Rails application database from node to local server'
  
  def run
    in_temp_dir do |dir|
      exec "#{scripts.webapp.db.dump_command scripts.webapp.db_name} > dump.sql"
      local_exec "mkdir -p tmp/db"
      download "#{dir}/dump.sql",
               :to => 'tmp/db/dump.sql',
               :sudo => true
    end
    
    scripts.webapp.db.create_database scripts.webapp.db_name, true
    
    local_exec "#{scripts.webapp.db.load_command scripts.webapp.db_name} < tmp/db/dump.sql"
  end
end
