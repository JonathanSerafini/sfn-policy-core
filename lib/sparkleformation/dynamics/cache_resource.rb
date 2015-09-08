
SparkleFormation.dynamic(:redis_cluster) do |_name, _config = {}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  outputs.set!("#{_name}_host") do
    value attr!(_name, "PrimaryEndPoint.Address")
  end

  resources.set!(_name) do
    type 'AWS::ElastiCache::ReplicationGroup'
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      engine: ref!(:cache_engine),
      port:   "6379",
      num_cache_clusters:       ref!(:cache_nodes),
      cache_node_type:          ref!(:cache_instance),
      cache_subnet_group_name:  ref!(:subnet_group_cache),
      security_group_ids:       array!(ref!(:security_group_cache)),
      automatic_failover_enabled:     "false",
      replication_group_description:  registry!(:context_name)

    registry! :resource_properties, :config
  end
end

SparkleFormation.dynamic(:memcache_cluster) do |_name, _config = {}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  outputs.set!("#{_name}_host") do
    value attr!(_name, "ConfigurationEndpoint.Address")
  end

  resources.set!(_name) do
    type 'AWS::ElastiCache::CacheCluster'
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      engine: ref!(:cache_engine),
      port:   "11211",
      cluster_name: registry!(:context_name),
      AZ_mode:      "cross-az",
      num_cache_clusters:       ref!(:cache_nodes),
      cache_node_type:          ref!(:cache_instance),
      vpc_security_group_ids:   array!(ref!(:security_group_cache)),
      cache_subnet_group_name:  ref!(:subnet_group_cache),
      cache_parameter_group_name:     nil

    registry! :resource_properties, :config
  end
end

SparkleFormation.dynamic(:cache_subnet_group) do |_name, _config = {}|
  resources.set!(_name) do
    type "AWS::ElastiCache::SubnetGroup"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      description: registry!(:context_name),
      subnet_ids: registry!(:context_subnets)
   
    registry! :resource_properties, :config
  end
end

