
SparkleFormation.build do
  registry! :bootstrap
  registry! :database_params

  dynamic! :security_group, :security_group_rds,
    state: { tier: :private, label: :rds },
    ingress_rules: [ { from_port: 3306 } ]

  dynamic! :database_subnet_group, :subnet_group_rds,
    state: { tier: :private }

  dynamic! :database_parameter_group, :parameter_group,
    state: { tier: :private }

  dynamic! :database_instance, :database

  dynamic! :record_set, :database_host,
    name: join!("db.", state!(:application), '.', ref!(:vpc_domain_name), '.'),
    type: "CNAME",
    TTL: 60,
    resource_records: [ attr!(:database, "Endpoint.Address") ]
end

