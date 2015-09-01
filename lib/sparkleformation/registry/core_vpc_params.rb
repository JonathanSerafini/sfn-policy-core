
#
# core_vpc_params
#
# Provides basic parameters inherited from the core_vpc template
#
SfnRegistry.register(:core_vpc_params) do
  parameters do
    #
    # VPC / Networking parameters
    #
    vpc_id do
      type "AWS::EC2::VPC::Id"
      description "VPC ID"
    end

    vpc_domain_id do
      type "String"
      description "VPC Route53 hosted zone id"
    end

    vpc_domain_name do
      type "String"
      description "VPC Route53 domain name"
    end

    vpc_availability_zones do
      type "CommaDelimitedList"
      description "VPC supported availability zones"
    end

    state!(:application_tiers).each do |_tier|
      _subnet_id = process_key!("vpc_#{_tier}_subnet_ids")
      set!(_subnet_id) do
        type "List<AWS::EC2::Subnet::Id>"
        description "VPC subnets for tier: #{_tier}"
      end
    end

    #
    # IAM parameters
    #
    vpc_default_role_id do
      type "String"
      description "Default IAM Role"
    end

    vpc_default_profile_id do
      type "String"
      description "Default IAM Profile"
    end

    vpc_security_group_id do
      type "String"
      description "VPC member security group"
    end
  end
end

