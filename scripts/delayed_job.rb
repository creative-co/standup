Standup.script :node do
  def run
    with_processed_file script_file('delayed_job_monit.conf') do |file|
      scripts.monit.add_watch file
    end
  end
  
  def restart
    scripts.monit.restart_watch 'delayed_job'
  end
end
