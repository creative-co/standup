Standup.script do
  self.description = 'Run remote Rails application console'
  
  def run
    scripts.shell.make_shell "cd /opt/webapp && rails console #{scripts.webapp.params.rails_env}"
  end
end
