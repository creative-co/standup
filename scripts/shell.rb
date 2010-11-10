Standup.script :node do
  self.description = 'Run remote shell (e.g. bash)'
  
  def run
    make_shell
  end
  
  def make_shell shell_command = ''
    return unless instance
    command = "#{node.ssh_string} -t '#{shell_command}'"
    bright_p command
    Kernel.exec command
  end
end
