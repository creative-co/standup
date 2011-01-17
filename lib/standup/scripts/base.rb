require 'active_support/hash_with_indifferent_access'

module Standup
  module Scripts
    class Base
      def initialize *args
        merge_params self.class.default_params
        merge_params Settings[name]
      end
    
      class_attribute :options
      self.options = ActiveSupport::HashWithIndifferentAccess.new
      
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
      
      def self.option name, opts
        self.options = ActiveSupport::HashWithIndifferentAccess.new options
        self.options[name] = opts
      end
      
      def option name, opts
        self.class.option name, opts
      end
      
      def self.get_option name, question = nil
        opts = options[name]
        
        return opts[:value] if opts.has_key? :value
        
        question ||= opts[:question] || "Please enter value for option #{name}:"
        
        case opts[:type]
          when :password
            bright_ask(question, false).strip.downcase == 'yes'
          when :flag
            bright_ask("#{question} [yes/NO]").strip.downcase == 'yes'
          when :argument
            raise "Required argument #{name} missing"
          else
            raise "Unknown type #{opts[:type]}"
        end
      end
      
      def get_option name, question = nil
        self.class.get_option name, question
      end
      
      def self.get_options
        options.select{|_,o| o.has_key? :value}.map_to_hash{|name, opts| {name => opts[:value]}}
      end
      
      def self.set_options values
        values.each do |name, value|
          opts = options[name]
          opts[:value] = value if opts
        end
      end
      
      def self.parse_options
        script_description = description
        script_name = name
        
        arguments = self.options.select{|_,o| o[:type] == :argument && !o.has_key?(:value)}
        options = self.options.select{|_,o| o[:type] != :argument}
        
        parser = Trollop::Parser.new do
          if script_description
            banner script_description
            banner ''
          end
          banner 'Usage:'
          usages = arguments.map{|_,o| "<#{o[:description]}>"}
          banner "       standup #{script_name} [options] #{usages.join(' ')}"
          banner ''
          arguments.each do |name, opts|
            if opts[:variants]
              banner "<#{name}> is one of the following:"
              banner ''
              opts[:variants].each { |v| banner v }
              banner ''
            end
          end
          banner "[options] are:"
          banner ''
          options.each do |name, opts|
            opts = opts.merge({:type => :string}) if opts[:type] == :password
            opt name, opts[:description], opts
          end

          stop_on_unknown
        end
        
        Trollop::with_standard_exception_handling parser do
          values = parser.parse ARGV
          
          arguments.each do |name, opts|
            argument = ARGV.shift or raise Trollop::HelpNeeded
            
            if opts[:variants] && !opts[:variants].include?(argument)
              parser.die "Unknown #{name} \"#{argument}\"", nil
            end
            
            opts[:value] = argument
          end
          
          options.each do |name, opts|
            opts[:value] = values[name.to_s] if values[:"#{name}_given"]
          end
        end
      end
      
      def merge_params param_overrides
        @params = if param_overrides.is_a? Hash
          ActiveSupport::HashWithIndifferentAccess.new((@params || {}).merge(param_overrides))
        else
          param_overrides || @params
        end
      end
      
      def get_binding
        binding
      end
    end
  end
end