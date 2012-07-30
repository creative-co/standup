module Standup
  module EC2
    class Volume < Base
      def initialize id, info = false
        @id = id
        super info
      end

      info_reader :id, :attached_to

      def self.list reload = false
        if !class_variable_defined?(:@@list) || reload
          @@list = {}
          response = api.describe_volumes
          response.volumeSet.item.each do |item|
            instance = item.attachmentSet ? Instance.new(item.attachmentSet.item[0].instanceId) : nil
            @@list[item.volumeId] = Volume.new item.volumeId,
                                                :status => item.status.to_sym,
                                                :attached_to => instance
          end if response.volumeSet
        end
        @@list
      end

      def self.create size
        response = api.create_volume :size => size.to_s,
                                     :availability_zone => Settings.aws.availability_zone
        list[response.volumeId] = Volume.new response.volumeId
      end

      def destroy
        api.delete_volume :volume_id => @id
        list.delete @id
      end

      def attach_to instance, device
        api.attach_volume :volume_id => @id,
                          :instance_id => instance.id,
                          :device => device
        @attached_to = instance
      end

      def detach
        api.detach_volume :volume_id => @id,
                          :force => 'true'
        @attached_to = nil
      end

      def load_info
        response = api.describe_volumes :volume_id => @id
        item = response.volumeSet.item[0]
        @status = item.status.to_sym
        @attached_to = item.attachmentSet ? Instance.new(item.attachmentSet.item[0].instanceId) : nil
      end
    end
  end
end
