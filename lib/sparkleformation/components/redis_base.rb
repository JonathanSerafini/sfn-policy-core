
SparkleFormation.build do
  registry! :bootstrap

  parameters do
    cache_nodes do
      type "String"
      description "Ammount of nodes in cache cluster"
      default "1"
    end

    cache_engine do
      type "String"
      description "Cache engine type"
      default "redis"
    end

    cache_instance do
      type "String"
      description "Cache instance type"
      default "cache.m3.medium"
    end
  end

  dynamic! :security_group, :security_group_cache,
    state: { tier: :private, label: :cache },
    ingress_rules: [ { from_port: 6379 } ]

  dynamic! :cache_subnet_group, :subnet_group_cache,
    state: { tier: :private }

  dynamic! :redis_cluster, :cache,
    state: { tier: :private }

  dynamic! :record_set, :cache_host,
    name: join!("cache.", state!(:application), '.', ref!(:vpc_domain_name), '.'),
    type: "CNAME",
    TTL: 60,
    resource_records: [ attr!(:cache, "PrimaryEndPoint.Address") ]
end

