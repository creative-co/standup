Standup.script :local do
  self.description = 'Request new Elasics IP to use in node config'
  
  def run
    bright_p "New IP: #{Standup::EC2::ElasticIP.create.ip}" 
  end
end
