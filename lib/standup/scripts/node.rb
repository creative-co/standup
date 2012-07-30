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
    
      delegate :download, :upload, :remote_update, :file_exists?, :install_package, :install_packages, :install_gem, :update_cron,
               :with_context, :exec, :sudo, :su_exec, :in_dir, :in_temp_dir, :as_user, :with_prefix, :remote_command,
               :to => :remoting
    
      attr_accessor :node
      
      def put_title
        bright_p "#{@node.name}:#{name}", HighLine::CYAN
      end
      
      option :nodes,
             :type => :argument,
             :description => 'node[,node]',
             :variants => ['all'] + Settings.nodes.keys
      
      unless Settings.nodes.keys.length > 1
        options[:nodes][:value] = 'all'
      end
      
      def self.execute
        nodes = get_option(:nodes).strip.split(',')
        nodes = Settings.nodes.keys if nodes.include?('all')
        
        run_on_nodes nodes
      end
      
      def self.run_on_nodes nodes
        nodes.each {|node| Standup::Node.new(node).run_script name}
      end
    end
  end
end
