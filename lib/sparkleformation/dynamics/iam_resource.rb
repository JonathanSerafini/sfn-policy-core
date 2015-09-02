
SparkleFormation.dynamic(:iam_group) do |_name, _config = {}|
  _config = {} if _config.nil?

  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    registry! :default_config, :config, 
      path: "/",
      policies: nil,
      managed_policy_arns: nil

    registry! :apply_config, :config, _config

    type "AWS::IAM::Group"

    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
    end
  end
end

SparkleFormation.dynamic(:iam_instance_profile) do |_name, _config = {}|
  _config = {} if _config.nil?

  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    registry! :default_config, :config, 
      path: "/",
      roles: nil

    registry! :apply_config, :config, _config

    type "AWS::IAM::InstanceProfile"

    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
    end
  end
end


SparkleFormation.dynamic(:iam_role) do |_name, _config = {}|
  _config = {} if _config.nil?

  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  outputs.set!("#{_name}_arn") do
    value attr!(_name, :arn)
  end

  resources.set!(_name) do
    registry! :default_config, :config, 
      path: "/",
      policies: nil,
      managed_policy_arns: nil,
      principal: { Service: "ec2.amazonaws.com" }

    registry! :apply_config, :config, _config

    type "AWS::IAM::Role"

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
  _config = {} if _config.nil?

  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    registry! :default_config, :config, 
      policy_name: _name,
      policy_document: nil,
      roles: nil,
      users: nil,
      groups: nil

    registry! :apply_config, :config, _config

    type "AWS::IAM::Policy"

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
  _config = {} if _config.nil?

  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    registry! :default_config, :config, 
      description: registry!(:context_name),
      policy_document: nil,
      roles: nil,
      users: nil,
      groups: nil

    registry! :apply_config, :config, _config

    type "AWS::IAM::ManagedPolicy"

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

