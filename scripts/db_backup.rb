klnblkblkbklblkcdStandup.script :node do
  def run
    exec "s3cmd mb #{bucket}"
    
    update_cron '@hourly', <<-CMD, :section => name
      #{scripts.webapp.db.dump_command scripts.webapp.db_name} | gzip > dump.gz
      s3cmd put dump.gz #{path_prefix}/`date -u +%Y-%m-%d/%H-%M-%S`.gz
      rm dump.gz
    CMD
  end
  
  protected
  
  def bucket
    "s3://#{Standup::Settings.webapp.name}-#{node.name}-standup-backup"
  end
  
  def path_prefix
    "#{bucket}/db/#{scripts.webapp.db_name}"
  end
end
