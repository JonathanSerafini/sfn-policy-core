
#
# sqs_queue
#
SparkleFormation.dynamic(:sqs_queue) do |_name, _config = {}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  resources.set!(_name) do
    type "AWS::SQS::Queue"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      delay_seconds: 0,
      maximum_message_size: nil,
      message_retention_period: 3600,
      queue_name: nil,
      visibility_timeout: 30

    registry! :resource_properties, :config
  end
end

