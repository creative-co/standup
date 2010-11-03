module Standup
  module EC2
    class ElasticIP < Base
      def initialize ip, info = false
        @ip = ip
        super info
      end

      info_reader :ip, :attached_to

      def self.list reload = false
        if !class_variable_defined?(:@@list) || reload
          @@list = {}
          result = api.describe_addresses
          result.addressesSet.item.each do |item|
            @@list[item.publicIp] = new item.publicIp, :attached_to => Instance.new(item.instanceId)
          end if result.addressesSet
        end
        @@list
      end

      def self.create
        ip = api.allocate_address.publicIp
        list[ip] = ElasticIP.new ip
      end

      def destroy
        api.release_address :public_ip => @ip
        list.delete @ip
      end

      def attach_to instance
        api.associate_address :instance_id => instance.id,
                              :public_ip => @ip
        @attached_to = instance
      end

      def detach
        api.disassociate_address :public_ip => @ip
        @attached_to = nil
      end

      def load_info
        result = api.describe_addresses :public_ip => @ip
        @attached_to = Instance.new(result.addressesSet.item[0].instanceId)
      end
    end
  end
end
