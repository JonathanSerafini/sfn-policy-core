
#
# launch_config
#
# Provides AutoScaling group's LaunchConfiguration
#
SparkleFormation.dynamic(:launch_config) do |_name, _config = {}|
  _config = {} if _config.nil?

  #
  # Extract nested resources
  #
  nested_configs = {}
  nested_dynamics = %w(
    metadata
    userdata
    block_devices
  )

  nested_dynamics.each do |key|
    default = case key.to_sym
              when :block_devices then []
              else {}
              end
    nested_configs[key.to_sym] = _config.delete(key.to_sym) || default
  end

  #
  # Resource
  #
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  _resource = resources.set!(_name) do
    type "AWS::AutoScaling::LaunchConfiguration"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      key_name:         ref!(:app_ami_keypair),
      image_id:         ref!(:app_ami_id),
      instance_type:    ref!(:app_instance),
      security_groups:  array!(
        ref!(:vpc_security_group_id),
        ref!(:security_group)
      ),
      associate_public_ip_address: state!(:tier) == "public",
      iam_instance_profile: ref!(:vpc_default_profile_id)

    registry! :resource_properties, :config
  end

  #
  # Process nested resources
  #

  dynamic! :metadata, _name, nested_configs[:metadata]
  dynamic! :launch_userdata, _name, nested_configs[:userdata]
  dynamic! :launch_devices, _name, nested_configs[:block_devices]

  # 
  # Return resource
  #
  _resource
end

SparkleFormation.dynamic(:launch_devices) do |_name, _config = []|
  resources.set!(_name) do
    registry! :default_config, :launch_devices,
      devices: []

    registry! :apply_config, :launch_devices,
      devices: _config if _config

    devices = state!(:launch_devices)[:devices].map do |hash|
      registry!(:block_mapping, hash)
    end

    unless devices.empty? 
      properties do
        block_device_mappings array!(*devices)
      end
    end
  end
end

SparkleFormation.dynamic(:launch_userdata) do |_name, _config = {}|
  resources.set!(_name) do
    registry! :resource_config, :userdata, _config,
      signal_resource: "ScalingGroup",
      config_sets: ["Chef"]
  end

  dynamic! :metadata_init_sets, _name, Chef: ["ChefInit", "ChefRun"]
  dynamic! :metadata_init_chef, _name

  resources.set!(_name) do
    properties do
      user_data base64!(join!(
        '#!/bin/bash', "\n",
        'export PATH="/usr/local/bin:$PATH"', "\n",
        "\n",
        'env_name=',    state!(:environment), "\n",
        'stack_name=',  ref!('AWS::StackName'), "\n",
        'region=',      ref!('AWS::Region'), "\n",
        'resource=',    state!(:userdata)[:signal_resource], "\n",
        'config_sets=', state!(:userdata)[:config_sets].join(','), "\n",
        "\n", "\n",
        "cfn-init",                         " \\","\n",
        "  --verbose",                      " \\", "\n",
        "  --stack",    " ${stack_name}",   " \\", "\n",
        "  --region",   " ${region}",       " \\", "\n",
        "  --resource", " #{process_key!(_name)}",        " \\", "\n",
        "  --configsets", " ${config_sets}",  " \\", "\n",
        "\n", "\n",
        "cfn-signal -e $?",                 " \\", "\n",
        "  --stack",    " ${stack_name}",   " \\", "\n",
        "  --region",   " ${region}",       " \\", "\n",
        "  --resource", " #{process_key!(_name)}",        " \\", "\n",
        "\n", "\n"
      ))
    end
  end
end

