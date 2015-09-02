
#
# subnet_route_table
# subnet_route
# subnet_route_table_assoc
#

SparkleFormation.dynamic(:subnet_route_table) do |_tier, _az, _config = {}|
  _config = {} if _config.nil?
  _prefix = "#{_tier}_#{_az}"
  _name = "#{_prefix}_table".to_sym

  _state = {
    tier: _tier,
    label: join!("-", _az, "-", _tier)
  }

  nested_configs = {}
  nested_dynamics = %w(
    routes
    state
    tags
  )

  nested_dynamics.each do |key|
    nested_configs[key.to_sym] = _config.delete(key.to_sym) || {}
  end

  nested_configs[:routes].each do |key, hash|
    hash[:route_table_id] = ref!(_name)
    route_name = "#{_prefix}_#{key}_route".to_sym
    dynamic! :subnet_route, route_name, hash
  end

  resources.set!(_name) do
    set_state!(_state.merge(nested_configs[:state]))

    registry! :default_config, :config, vpc_id: ref!(:vpc_id)
    registry! :apply_config, :config, _config
    registry! :apply_config, :tags, nested_configs[:tags]

    type "AWS::EC2::RouteTable"

    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
      tags registry!(:context_tags)
    end
  end
end

SparkleFormation.dynamic(:subnet_route) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    registry! :default_config, :config,
      route_table_id: nil,
      network_interface_id: nil,
      vpc_peering_connection_id: nil,
      instance_id: nil,
      gateway_id: nil,
      destination_cidr_block: nil

    registry! :apply_config, :config,
      _config

    type "AWS::EC2::Route"

    properties do
      state!(:config).each do |k,v|
        set!(k,v)
      end
    end
  end
end

SparkleFormation.dynamic(:subnet) do |_tier, _az, _config = {}|
  _config = {} if _config.nil?
  _state = {
    tier: _tier,
    label: join!("-", _az, "-", _tier)
  }

  _name         = "#{_tier}_#{_az}_table".to_sym
  _param_name   = "vpc_cidr_#{_az}_#{_tier}".to_sym
  _subnet_name  = "#{_tier}_#{_az}_subnet".to_sym
  _table_name   = "#{_tier}_#{_az}_table".to_sym
  _assoc_name   = "#{_tier}_#{_az}_assoc".to_sym

  nested_configs = {}
  nested_dynamics = %w(
    routes
    state
    tags
  )

  nested_dynamics.each do |key|
    nested_configs[key.to_sym] = _config.delete(key.to_sym) || {}
  end

  resources.set!(_name) do
    set_state!(_state.merge(nested_configs[:state]))

    registry! :default_config, :config,
      vpc_id: ref!(:vpc_id),
      availability_zone: join!(ref!('AWS::Region'), _az),
      cidr_suffix: nil

    registry! :apply_config, :tags, 
      nested_configs[:tags]

    registry! :apply_config, :config, 
      _config

    _config = state!(:config)
  end

  parameters.set!(_param_name) do
    type "String"
    description "Subnet CIDR suffix for AZ 10.{vpc}.xx.xx/xx"
    default _config[:cidr_suffix]
    allowed_pattern "\\d{1,3}+.\\d{1,3}+/\\d\\d"
  end

  dynamic! :subnet_route_table, _tier, _az,
    vpc_id: _config[:vpc_id],
    routes: nested_configs[:routes]

  resources.set!(_subnet_name) do
    type "AWS::EC2::Subnet"
    properties do
      vpc_id _config[:vpc_id]
      availability_zone _config[:availability_zone]
      cidr_block join!(ref!(:vpc_cidr_prefix), '.', _config[:cidr_suffix])
      tags registry!(:context_tags)
    end
  end

  registry! :default_config, :subnets, _tier => []
  state!(:subnets)[_tier] << ref!(_subnet_name)

  outputs.set!("vpc_#{_tier}_subnet_ids") do
    value join!(*state!(:subnets)[_tier],{options:{delimiter:','}})
  end
end

