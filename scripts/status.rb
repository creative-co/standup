Standup.script do
  self.description = 'Check nodes status and display useful info'
  
  def run
    if instance
      puts "Node:        #{node.name}"
      puts "State:       #{instance.state}"
      puts "IP:          #{instance.external_ip}"
      puts "SSH String:  #{node.ssh_string}"
    else
      puts "Node:        #{node.name}"
      puts "State:       not running"
    end
  end
end
