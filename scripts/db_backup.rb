Standup.script :node do
  self.description = 'Rails application database periodic backup to S3'
  
  def run
    exec "s3cmd mb #{bucket}"
    
    update_cron '@hourly', <<-CMD, :section => name
      touch dump.gz
      sudo chmod 666 dump.gz
      sudo su -c "pg_dump -c #{scripts.webapp.db_name} | gzip > dump.gz" postgres
      s3cmd put dump.gz #{path_prefix}/`date -u +%Y-%M-%d/%H_%m_%S`.gz
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
