
SparkleFormation.dynamic(:redis_group) do |_name, _config = {}|
  _config = {} if _config.nil?

  outputs.set("#{_name}_id") do
    value ref!(_name)
  end

  outputs.set("#{_name}_host") do
    value attr!(_name, "PrimaryEndPoint.Address")
  end

  resources.set!(_name) do
    registry! :default_config, :config, 
      engine: ref!(:cache_engine),
      port:   "6379",
      num_cache_clusters:       ref!(:cache_nodes),
      cache_node_type:          ref!(:app_instance),
      cache_subnet_group_name:  ref!(:subnet_group_cache),
      security_group_ids:       array!(ref!(:security_group_cache)),
      automatic_failover_enabled:     "false",
      replication_group_description:  registry!(:context_name)

    registry! :apply_config, :config,
      _config

    type 'AWS::ElastiCache::ReplicationGroup'

    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
    end
  end
end

SparkleFormation.dynamic(:cache_subnet_group) do |_name, _config={}|
  _config = {} if _config.nil?

  nested_configs = {}
  nested_dynamics = %w(state)
  nested_dynamics.each do |key|
    nested_configs[key.to_sym] = _config.delete(key.to_sym) || {}
  end

  resources.set!(_name) do
    set_state!(nested_configs[:state])

    registry :default_config, :config, 
      description: registry!(:context_name),
      subnet_ids: registry!(:context_subnets)

    registry! :apply_config, :config,
      _config
    
    type "AWS::ElastiCache::SubnetGroup"

    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
    end
  end
end

