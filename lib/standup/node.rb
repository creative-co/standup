require 'active_support/hash_with_indifferent_access'

module Standup
  class Node
    def initialize name
      @name = name
      
      @scripts = ActiveSupport::HashWithIndifferentAccess.new
      Standup.scripts.each do |sname, script|
        @scripts[sname] = script.new self
      end
      @remoting = nil
    end
    
    attr_reader :name, :scripts
    
    def run_script script_name
      scripts[script_name].put_title
      scripts[script_name].run
      close_remoting
    end
    
    def instance
      @instance ||= EC2::Instance.group_running[id_group].try(:first)
    end
    
    def ssh_string
      return '' unless instance
      "ssh -i #{Settings.aws.keypair_file} -q -o StrictHostKeyChecking=no #{params.ec2.ssh_user}@#{instance.external_ip}"
    end
    
    def params
      Settings.nodes[@name] || ActiveSupport::HashWithIndifferentAccess.new
    end
    
    def remoting
      @remoting ||= Remoting.new self
    end
    
    def id_group
      "standup_node_#{@name}"
    end
    
    protected
    
    def close_remoting
      @remoting.close if @remoting
      @remoting = nil
    end
  end
end