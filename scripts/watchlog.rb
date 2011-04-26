Standup.script :node do
  self.description = 'Watch remote Rails application log'
  
  def run
    scripts.shell.make_shell "tail -n 1000 -f #{scripts.webapp.app_path}/log/#{scripts.webapp.params.rails_env}.log"
  end
end
