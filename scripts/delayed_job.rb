Standup.script do
  def run
    scripts.monit.add_watch script_file('delayed_job_monit.conf')
  end
  
  def restart
    scripts.monit.restart_watch 'delayed_job'
  end
end
