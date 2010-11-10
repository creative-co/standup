Standup.script do
  self.description = 'Watch remote Rails application log'
  
  def run
    scripts.shell.make_shell "tail -n 1000 -f /opt/webapp/log/#{scripts.webapp.params.rails_env}.log"
  end
end
