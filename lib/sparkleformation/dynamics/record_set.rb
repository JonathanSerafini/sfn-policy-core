
SparkleFormation.dynamic(:record_set) do |_name, _config = {}|
  outputs.set!(_name) do
    value ref!(_name)
  end

  resources.set!(_name) do
    type "AWS::Route53::RecordSet"
    set_state(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      health_check_id: id,
      hosted_zone_id: ref!(:vpc_domain_id),
      name: nil,
      comment: nil, 
      resource_records: nil,
      alias_target: nil, 
      TTL: nil, 
      type: 'A'

    properties do
      state!(:config).each do |key, value|
        if key == "alias_target"
          value[:hosted_zone_id] ||= "Z3DZXE0Q79N41H" # TODO .. map per region?
          value = Hash[value.map{|k,v| [process_key!(k),v]}]
        end

        set!(key, value)
      end
    end
  end
end

SparkleFormation.dynamic(:record_health_check) do |_name, _config = {}|
  resources.set!(_name) do
    type "AWS::Route53::HealthCheck"
    set_state(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      type: "HTTP",
      resource_path: "/_lightspeed/health",
      failure_threshold: 6,
      request_interval: 10

    properties do
      health_check_config do
        state!(:config).each do |key, value|
          set!(key, value)
        end
      end
    end
  end
end

