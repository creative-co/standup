Standup.script :node do
  self.description = 'Run remote shell (e.g. bash)'
  
  def run
    make_shell
  end
  
  def make_shell shell_command = ''
    return unless instance
    command = "#{ssh_string} -t '#{shell_command}'"
    bright_p command
    Kernel.exec command
  end

  protected

  def ssh_string
    return '' unless instance
    "ssh -i #{Standup::Settings.aws.keypair_file} -C -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null #{params.extra_options} #{scripts.ec2.params.ssh_user}@#{instance.external_ip}"
  end
end
