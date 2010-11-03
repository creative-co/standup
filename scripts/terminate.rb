Standup.script do
  self.description = 'Terminate nodes'
  
  def run
    return unless instance
    if bright_ask("Do you really want to terminate node #{node.name}? [yes/NO]").strip.downcase == 'yes'
      instance.terminate
    else
      bright_p "aborted"
    end
  end
end
