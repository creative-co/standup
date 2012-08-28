module Standup
  module EC2
    class Base
      def initialize info = false
        case info
          when Hash
            set_info info
          when true
            load_info
          when false
            # nothing
        end
      end

      def self.info_reader *names
        names.each do |name|
          class_eval "def #{name}; read_info_field :#{name}; end", __FILE__, __LINE__
        end
      end

      def exists?
        read_info_field :exists
      end

      def load_info; end

      protected

      def read_info_field name
        load_info unless instance_variable_defined?(:"@#{name}")
        instance_variable_set(:"@#{name}", nil) unless instance_variable_defined?(:"@#{name}")
        @exists = true
        instance_variable_get(:"@#{name}")
      rescue AWS::InvalidGroupNotFound
      rescue AWS::InvalidInstanceIDNotFound
      rescue AWS::InvalidVolumeIDNotFound
        @exists = false
        nil
      end

      def set_info info
        info.each do |key, value|
          instance_variable_set :"@#{key}", value
        end
      end

      def list
        self.class.list
      end

      def api
        self.class.api
      end

      def self.api
        @@api ||= AWS::EC2::Base.new :access_key_id => Settings.aws.access_key_id,
                                     :secret_access_key => Settings.aws.secret_access_key,
                                     :server => "ec2.#{Settings.aws.availability_zone[/\w+-\w+-\d+/]}.amazonaws.com"
      end
    end
  end
end
