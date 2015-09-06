
SparkleFormation.dynamic(:iam_group) do |_name, _config = {}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    type "AWS::IAM::Group"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config, 
      path: "/",
      policies: nil,
      managed_policy_arns: nil

    registry! :resource_properties, :config
  end
end

SparkleFormation.dynamic(:iam_instance_profile) do |_name, _config = {}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    type "AWS::IAM::InstanceProfile"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      path: "/",
      roles: nil

    registry! :resource_properties, :config
  end
end

SparkleFormation.dynamic(:iam_role) do |_name, _config = {}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  outputs.set!("#{_name}_arn") do
    value attr!(_name, :arn)
  end

  resources.set!(_name) do
    type "AWS::IAM::Role"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      path: "/",
      policies: nil,
      managed_policy_arns: nil,
      principal: { Service: "ec2.amazonaws.com" }

    properties do
      state!(:config).each do |key, value|
        case key.to_sym
        when :policies
          value = registry!(:iam_policies, value)
        when :principal
          key = :assume_role_policy_document
          value = registry!(:iam_policy_document, statement: [
            {
              effect: "Allow",
              action: "sts:AssumeRole",
              principal: value
            }
          ])
        end

        set!(key, value)
      end
    end
  end
end

SparkleFormation.dynamic(:iam_policy) do |_name, _config = {}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    type "AWS::IAM::Policy"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      policy_name: _name,
      policy_document: nil,
      roles: nil,
      users: nil,
      groups: nil

    properties do
      state!(:config).each do |key, value|
        case key.to_sym
        when :policy_document
          value = registry!(:iam_policy_document, value)
        end
        set!(key, value)
      end
    end
  end
end

SparkleFormation.dynamic(:iam_managed_policy) do |_name, _config = {}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    type "AWS::IAM::ManagedPolicy"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      description: registry!(:context_name),
      policy_document: nil,
      roles: nil,
      users: nil,
      groups: nil

    properties do
      state!(:config).each do |key, value|
        case key.to_sym
        when :policy_document
          value = registry!(:iam_policy_document, value)
        end
        set!(key, value)
      end
    end
  end
end

