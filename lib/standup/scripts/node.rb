module Standup
  module Scripts
    class Node < Base
      def initialize node
        super
        merge_params node.params[name]
        @node = node
        @remoting = nil
      end
      
      delegate :instance, :open_port, :open_ports, :remoting, :scripts,
               :to => :@node
    
      delegate :download, :upload, :remote_update, :exec, :sudo, :su_exec, :in_dir, :in_temp_dir, :file_exists?, :install_package, :install_packages, :install_gem, :update_cron,
               :to => :remoting
    
      attr_accessor :node
      
      def put_title
        bright_p "#{@node.name}:#{name}", HighLine::CYAN
      end
      
      if Settings.nodes.keys.length > 1
        option :nodes,
               :type => :argument,
               :description => 'node[,node]',
               :variants => ['all'] + Settings.nodes.keys
      end
      
      def self.execute
        parse_options
        
        nodes = get_option(:nodes).strip.split(',')
        nodes = Settings.nodes.keys if !nodes || nodes.include?('all')
        
        run_on_nodes nodes
      end
      
      def self.run_on_nodes nodes
        nodes.each {|node| Standup::Node.new(node).run_script name}
      end
    end
  end
end
