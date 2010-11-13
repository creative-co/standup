require 'active_support/hash_with_indifferent_access'

module Standup
  module Scripts
    class Base
      def initialize *args
        merge_params self.class.default_params
        merge_params Settings[name]
      end
    
      class_attribute :name
      
      class_attribute :default_params
      self.default_params = {}
      
      class_attribute :description
      
      attr_accessor :params
      
      def name
        self.class.name
      end
      
      def put_title
        bright_p name, HighLine::CYAN
      end
      
      def script_file filename
        [Standup.local_scripts_path, Standup.gem_scripts_path].each do |dir|
          next unless dir
          path = File.expand_path("#{name}/#{filename}", dir)
          return path if File.exists? path
        end
        nil
      end
      
      def with_processed_file filename
        Dir.mktmpdir do |dir|
          erb = ERB.new File.read(filename)
          erb.filename = filename
          result = erb.result get_binding
          tmp_filename = File.expand_path File.basename(filename), dir 
          File.open(tmp_filename, 'w') {|f| f.write result}
          yield tmp_filename
        end
      end
      
      def self.execute
        new.run
      end
      
      protected
      
      def merge_params param_overrides
        @params = if param_overrides.is_a? Hash
          ActiveSupport::HashWithIndifferentAccess.new((@params || {}).merge(param_overrides))
        else
          param_overrides || @params
        end
      end
      
      def argument arg_pattern, arg_name = arg_pattern, variants = nil
        self.class.argument arg_pattern, arg_name, variants
      end

      def self.argument arg_pattern, arg_name = arg_pattern, variants = nil
        script_description = description
        script_name = name
        opt_parser = Trollop::Parser.new do
          banner script_description
          banner ''
          banner 'Usage:'
          banner "       standup #{script_name} [options] #{arg_pattern}"
          banner ''
          if variants
            banner "where <#{arg_name}> is one of the following:"
            banner ''
            variants.each { |v| banner v }
            banner ''
          end
          banner "and [options] are:"
          banner ''

          stop_on_unknown
        end
        Trollop::with_standard_exception_handling opt_parser do
          opt_parser.parse ARGV
          raise Trollop::HelpNeeded if ARGV.empty?
        end
        
        result = ARGV.shift
        if variants && !variants.include?(result)
          opt_parser.die "unknown #{arg_name} #{result}", nil
        end
        result
      end
      
      def get_binding
        binding
      end
    end
  end
end