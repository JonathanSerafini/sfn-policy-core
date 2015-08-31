
#
# sqs_queue
#
SparkleFormation.dynamic(:template) do |_name, _config = {}|
  _config = {} if _config.nil?

  #
  # Extract nested non-standard hashes
  #
  nested_dynamics = %w(
  )

  nested_configs = {}
  nested_dynamics.each do |key|
    nested_configs[key.to_sym] = _config.delete(key.to_sym) || {}
  end

  #
  # Create an output referencing the resource
  #
  outputs.set!("#{_name}_url") do
    value ref!(_name)
  end

  #
  # Create the resource configuration
  #
  resources.set!(_name) do
    set_state!(nested_configs[:state])

    registry! :default_config, :config,
      delay_seconds: 0,
      maximum_message_size: nil,
      message_retention_period: 3600,
      queue_name: nil,
      visibility_timeout: 30
    
    registry! :apply_config, :config,
      _config
  end

  #
  # Create the resources
  #
  resources.set!(_name) do
    type "AWS::SQS::Queue"
    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
    end
  end
end

