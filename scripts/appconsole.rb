Standup.script do
  self.description = 'Run remote Rails application console'
  
  def run
    Kernel.exec "#{node.ssh_string} -t 'cd /opt/webapp && rails console #{scripts.webapp.params.rails_env}'".tap(&:bright_p)
  end
end
