module Standup
  module EC2
    class SecurityGroup < Base
      IPRule = Struct.new(:ip, :protocol, :from_port, :to_port)

      def initialize name, info = false
        @name = name
        super info
      end

      info_reader :name, :description, :rules

      def self.list reload = false
        if !class_variable_defined?(:@@list) || reload
          @@list = {}
          result = api.describe_security_groups
          result.securityGroupInfo.item.each do |gitem|
            @@list[gitem.groupName] = new gitem.groupName, build_info(gitem)
          end if result.securityGroupInfo
        end
        @@list
      end

      def self.create name, description = name
        api.create_security_group :group_name => name,
                                  :group_description => description
        list[name] = SecurityGroup.new name,
                                       :description => description,
                                       :rules => []
      end

      def delete
        api.delete_security_group :group_name => @name
        list.delete @name
      end

      def add_rule rule
        api.authorize_security_group_ingress build_rules_opts(rule)
        rules << rule
      end

      def remove_rule rule
        api.revoke_security_group_ingress build_rules_opts(rule)
        rules.delete rule
      end

      def load_info
        result = api.describe_security_groups :group_name => [@name]
        set_info self.class.build_info(result.securityGroupInfo.item[0])
      end

      def hash
        @name.hash
      end

      def eql? other
        @name == other.name
      end

      private

      def build_rules_opts rule
        case rule
          when SecurityGroup
            return :group_name => @name,
                   :source_security_group_name => rule.name,
                   :source_security_group_owner_id => Settings.aws.account_id
          when IPRule
            return :group_name => @name,
                   :ip_protocol => rule.protocol,
                   :from_port => rule.from_port,
                   :to_port => rule.to_port,
                   :cidr_ip => rule.ip
        end
      end

      def self.build_info gitem
        rules = Set.new
        gitem.ipPermissions.item.each do |pitem|
          rules << if pitem.groups
            SecurityGroup.new pitem.groups.item[0].groupName
          else
            IPRule.new pitem.ipRanges.item[0].cidrIp,
                       pitem.ipProtocol,
                       pitem.fromPort,
                       pitem.toPort
          end
        end if gitem.ipPermissions

        return :description => gitem.groupDescription,
               :rules => rules
      end
    end
  end
end
