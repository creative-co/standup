Standup.script :node do
  self.description = 'Terminate nodes'
  
  option :force,
         :type => :flag,
         :description => 'Forse node termination'
  
  def run
    return unless instance
    
    if get_option :force, "Do you really want to terminate node #{node.name}?"
      instance.terminate
    else
      bright_p "aborted"
    end
  end
end
