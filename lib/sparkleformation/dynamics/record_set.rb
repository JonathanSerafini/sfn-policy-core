
SparkleFormation.dynamic(:record_set) do |_name, _config = {}|
  _config = {} if _config.nil?

  outputs.set!(_name) do
    value ref!(_name)
  end

  resources.set!(_name) do
    registry! :default_config, :config, 
      health_check_id: id,
      hosted_zone_id: ref!(:vpc_domain_id),
      name: nil,
      comment: nil, 
      resource_records: nil,
      alias_target: nil, 
      TTL: nil, 
      type: 'A'

    registry! :apply_config, :config, 
      _config

    type "AWS::Route53::RecordSet"

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
  _config = {} if _config.nil?

  resources.set!(_name) do
    registry! :default_config, :config,
      type: "HTTP",
      resource_path: "/_lightspeed/health",
      failure_threshold: 6,
      request_interval: 10

    registry! :apply_config, :config,
      _config

    type "AWS::Route53::HealthCheck"

    properties do
      health_check_config do
        state!(:config).each do |key, value|
          set!(key, value)
        end
      end
    end
  end
end

