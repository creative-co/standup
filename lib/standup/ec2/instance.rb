module Standup
  module EC2
    class Instance < Base
      def initialize id, info = false
        @id = id
        super info
      end

      info_reader :id, :external_ip, :internal_ip, :state, :security_groups, :architecture

      def self.list reload = false
        if !class_variable_defined?(:@@list) || reload
          @@list = {}
          result = api.describe_instances
          result.reservationSet.item.each do |ritem|
            ritem.instancesSet.item.each do |item|
              @@list[item.instanceId] = new item.instanceId, build_info(ritem, item)
            end if ritem.instancesSet
          end if result.reservationSet
        end
        @@list
      end
      
      def self.group_running reload = false
        result = {}
        SecurityGroup.list(reload).each {|name, _| result[name] = []}
        list(reload).each do |_, instance|
          instance.security_groups.each do |sg|
            result[sg.name] << instance
          end unless [:terminated, :"shutting-down"].include?(instance.state)
        end
        result
      end

      def self.create image_id, instance_type, security_groups
        response = api.run_instances :image_id => image_id,
                                     :key_name => Settings.aws.keypair_name,
                                     :instance_type => instance_type,
                                     :security_group => security_groups.map(&:name),
                                     :availability_zone => Settings.aws.availability_zone
        id = response.instancesSet.item[0].instanceId
        list[id] = Instance.new id
      end

      def terminate
        api.terminate_instances :instance_id => @id
      end

      def reboot
        api.reboot_instances :instance_id => @id
      end
      
      def wait_until timeout = 300
        sleeping = 0
        while yield(self) && sleeping < timeout
          sleeping += sleep 5
          STDOUT.print '.'
          STDOUT.flush
          load_info
        end
        print "\n"
      end

      def load_info
        ritem = api.describe_instances(:instance_id => @id).reservationSet.item[0]
        set_info self.class.build_info(ritem, ritem.instancesSet.item[0])
      end

      protected

      def self.build_info ritem, item
        return :external_ip => item.ipAddress,
               :internal_ip => item.privateIpAddress,
               :state => item.instanceState.name.to_sym,
               :architecture => item.architecture,
               :security_groups => ritem.groupSet.item.map{|i| SecurityGroup.new(i.groupId)}
      end
    end
  end
end
