
#
# security_params
#
# Provides the basic parameters for dealing IAM and Security Groups
#
# @registry  :context_init
# 
SfnRegistry.register(:security_params) do
  parameters do
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

