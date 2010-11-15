Standup.script :node do
  self.description = 'Run remote Rails application console'
  
  def run
    scripts.shell.make_shell "cd #{scripts.webapp.app_path} && rails console #{scripts.webapp.params.rails_env}"
  end
end
