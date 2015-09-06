
SparkleFormation.dynamic(:database_instance) do |_name, _config={}|
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end

  outputs.set!("#{_name}_host") do
    value attr!(_name, "Endpoint.Address")
  end

  resources.set!(_name) do
    type 'AWS::RDS::DBInstance'
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config, 
      engine:                   "mysql",
      DB_name:                  if state!(:label)
                                then join!(
                                    state!(:application),
                                    state!(:label)
                                  )
                                else state!(:application)
                                end,
      DB_instance_class:        ref!(:db_instance),
      DB_parameter_group_name:  ref!(:parameter_group),
      DB_subnet_group_name:     ref!(:subnet_group_rds),
      VPC_security_groups:      array!(ref!(:security_group_rds)),
      allocated_storage:        ref!(:db_disk_size),
      storage_type:             ref!(:db_disk_type),
      backup_retention_period:  ref!(:db_backup_retention),
      master_username:          ref!(:db_username),
      master_user_password:     ref!(:db_password),
      multi_AZ:                 true,
      publicly_accessible:      false,
      allow_major_version_upgrade: false,
      allow_minor_version_upgrade: false

    registry! :resource_properties, :config
  end
end

SparkleFormation.dynamic(:database_parameter_group) do |_name, _config={}|
  resources.set!(_name) do
    type 'AWS::RDS::DBParameterGroup'
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config, 
      family: "MySQL5.6",
      parameters: {}

    registry! :resource_properties, :config
  end
end

SparkleFormation.dynamic(:database_subnet_group) do |_name, _config={}|
  resources.set!(_name) do
    type "AWS::RDS::DBSubnetGroup"
    set_state!(_config.delete(:state) || {})

    registry! :resource_config, :config, _config,
      DB_subnet_group_description: registry!(:context_name),
      subnet_ids: registry!(:context_subnets)

    registry! :resource_properties, :config
  end
end

