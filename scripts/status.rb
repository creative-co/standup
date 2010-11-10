Standup.script :node do
  self.description = 'Check nodes status and display useful info'
  
  def run
    if instance
      puts "Node:        #{node.name}"
      puts "State:       #{instance.state}"
      puts "IP:          #{instance.external_ip}"
    else
      puts "Node:        #{node.name}"
      puts "State:       not running"
    end
  end
      
  def self.execute
    run_on_nodes Standup::Settings.nodes.keys
  end
end
