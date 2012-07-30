Standup.script :node do
  self.description = 'Run remote Rails application console'
  
  def run
    scripts.webapp.with_environment do
      scripts.shell.make_shell(remote_command('rails console'))
    end
  end
end
