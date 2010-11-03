Standup.script do
  def run
    ensure_security_group
      
    open_port 22
      
    ensure_instance
      
    configure_elastic_ip
  end
  
  def open_ports *ports
    ports.map(&:to_s).each do |port|
      rule = Standup::EC2::SecurityGroup::IPRule.new('0.0.0.0/0', 'tcp', port, port)
      group = Standup::EC2::SecurityGroup.list[node.id_group]
      unless group.rules.include? rule
        bright_p "opening port #{port}"
        group.add_rule rule
      end
    end
  end
  alias :open_port :open_ports
  
  protected
  
  def ensure_security_group
    return if Standup::EC2::SecurityGroup.list[node.id_group]
    
    bright_p "creating security group #{node.id_group}"
    Standup::EC2::SecurityGroup.create node.id_group
  end
  
  def ensure_instance
    return if instance
    
    bright_p "launching #{params.instance_type} instance with image #{params.image_id}"
    inst = Standup::EC2::Instance.create params.image_id,
                                         params.instance_type,
                                         [Standup::EC2::SecurityGroup.list[node.id_group]]
    puts "waiting until it's up"
    inst.wait_until {inst.state != :running}
  end
  
  def configure_elastic_ip
    if params.elastic_ip
      unless params.elastic_ip == instance.external_ip
        bright_p "attaching elastic ip #{params.elastic_ip}"
        Standup::EC2::ElasticIP.list[params.elastic_ip].attach_to instance
        
        puts "waiting until it's attached"
        instance.wait_until {instance.external_ip != params.elastic_ip}
      end
    else
      if ip = Standup::EC2::ElasticIP.list[instance.external_ip]
        bright_p "detaching elastic ip #{params.elastic_ip}"
        ip.detach
      end
    end
  end
end
