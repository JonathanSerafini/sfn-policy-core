
#
# instance_params
#
# Provides the basic parameters for dealing with nodes
#
# @registry  :context_init
# 
SfnRegistry.register(:instance_params) do
  parameters do
    app_instance do
      type "String"
      description "Instance node type"
      default "m3.medium"
    end
  end
end

SfnRegistry.register(:ami_params) do
  parameters do
    app_ami_id do
      type "String"
      description "Instance AMI"
    end

    app_ami_keypair do
      type "AWS::EC2::KeyPair::KeyName"
      description "Instance SSH keypair"
      default 'ghost'
    end

    chef_runlist do
      type "CommaDelimitedList"
      description "Instance chef runlist"
    end
  end
end

