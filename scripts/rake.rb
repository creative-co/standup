Standup.script :node do
  self.description = 'Run remote Rake task'
  
  def run
    scripts.shell.make_shell "cd #{scripts.webapp.app_path} && RAILS_ENV=#{scripts.webapp.params.rails_env} sudo -u www-data rake #{ARGV.join(' ')}" 
  end
end
