Standup.script do
  self.description = 'Run remote shell (e.g. bash)'
  
  def run
    Kernel.exec "#{node.ssh_string} -t".tap(&:bright_p)
  end
end
