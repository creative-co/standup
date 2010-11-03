require 'active_support/hash_with_indifferent_access'

module Standup
  module Scripts
    class Base
      def initialize node
        @node = node
        @remoting = nil
        @params = if node.params[name].is_a? Hash
          ActiveSupport::HashWithIndifferentAccess.new self.class.default_params.merge(node.params[name])
        else
          node.params[name] || self.class.default_params
        end
      end
    
      class_attribute :name
      
      class_attribute :default_params
      self.default_params = {}
      
      class_attribute :description
      
      delegate :instance, :open_port, :open_ports, :remoting, :scripts,
               :to => :@node
    
      delegate :download, :upload, :remote_update, :exec, :sudo, :in_dir, :in_temp_dir, :file_exists?, :install_package, :install_packages, :install_gem,
               :to => :remoting
    
      attr_accessor :node, :params
      
      def name
        self.class.name
      end
      
      def titled_run
        bright_p "#{@node.name}:#{name}", HighLine::CYAN
        run
      end
      
      def run; end
    end
  end
end