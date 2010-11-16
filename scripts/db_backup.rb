Standup.script :node do
  def run
    exec "s3cmd mb #{bucket}"
    
    update_cron '@hourly', <<-CMD, :section => name
      touch dump.gz
      sudo chmod 666 dump.gz
      sudo su -c "pg_dump -c #{scripts.webapp.db_name} | gzip > dump.gz" postgres
      s3cmd put dump.gz #{path_prefix}/`date -u +%Y-%m-%d/%H-%M-%S`.gz
      rm dump.gz
    CMD
  end
  
  protected
  
  def bucket
    's3://standup-backup'
  end
  
  def path_prefix
    "#{bucket}/db/#{scripts.webapp.db_name}"
  end
end
