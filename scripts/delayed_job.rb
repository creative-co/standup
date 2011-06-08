Standup.script :node do
  def run
    path_to_resque_exec = "#{scripts.webapp.app_path}/script/delayed_job"
    with_processed_file script_file('delayed_job') do |file|
      upload file,
             :to => path_to_resque_exec,
             :sudo => true
    end

    with_processed_file script_file('delayed_job_monit.conf') do |file|
      scripts.monit.add_watch file
    end
  end
  
  def restart
    scripts.monit.restart_watch 'delayed_job'
  end
end
