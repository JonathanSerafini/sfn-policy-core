
#
# load_balancer
#
# Creates a EC2 Load Balancer
#
SparkleFormation.dynamic(:load_balancer) do |_name, _config = {}|
  _config = {} if _config.nil?

  registry! :context_params
  registry! :network_params
  registry! :security_params

  #
  # Extract nested non-standard hashes
  #
  nested_configs = {}
  nested_dynamics = %w(
    listeners
    draining_policy
    connection_settings
    health_check
    state
    tags
  )

  nested_dynamics.each do |key|
    nested_configs[key.to_sym] = _config.delete(key.to_sym) || {}
  end

  #
  # Create an output referencing the resource
  #
  outputs.set!("#{_name}_id") do
    value ref!(_name)
  end
  
  outputs.set!("#{_name}_host") do
    value attr!(_name, "DNSName")
  end

  #
  # Create the resource configuration
  #
  resources.set!(_name) do
    set_state!(nested_configs[:state])

    registry! :default_config, :config,
      load_balancer_name: registry!(:context_name),
      scheme: if state!(:tier) == :public
                then "internet-facing"
                else "internal"
              end,
      cross_zone: true,
      security_groups: array!(
        ref!(:security_group_elb),
        ref!(:vpc_security_group_id)
      ),
      subnets: registry!(:context_subnets)

    registry! :apply_config, :config,
      _config
  end

  #
  # Create the nested resources
  #
  dynamic! :load_balancer_health, _name, nested_configs[:health_check]
  dynamic! :load_balancer_settings, _name, nested_configs[:connection_settings]
  dynamic! :load_balancer_policy, _name, nested_configs[:draining_policy]
  dynamic! :load_balancer_listeners, _name, nested_configs[:listeners]

  #
  # Create the resources
  #
  resources.set!(_name) do
    type "AWS::ElasticLoadBalancing::LoadBalancer"
    registry! :load_balancer_ssl_policies

    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
      tags registry!(:context_tags)
    end
  end
end

SparkleFormation.dynamic(:load_balancer_health) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    registry! :default_config, :health,
      healthy_threshold: 6,
      unhealthy_threshold: 3,
      target: nil,
      interval: 10,
      timeout: 5

    registry! :apply_config, :health, 
      _config

    unless state!(:health).empty?
      properties do
        health_check do
          state!(:health).each do |key, value|
            set!(key, value)
          end
        end
      end
    end
  end
end

SparkleFormation.dynamic(:load_balancer_settings) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    registry! :default_config, :settings,
      idle_timeout: 60

    registry! :apply_config, :settings, 
      _config

    unless state!(:settings).empty?
      properties do
        connection_settings do
          state!(:settings).each do |key, value|
            set!(key, value)
          end
        end
      end
    end
  end
end

SparkleFormation.dynamic(:load_balancer_policy) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    registry! :default_config, :policy,
      enabled: true,
      timeout: 120

    registry! :apply_config, :policy, 
      _config

    unless state!(:policy).empty?
      properties do
        connection_draining_policy do
          state!(:policy).each do |key, value|
            set!(key, value)
          end
        end
      end
    end
  end
end

SparkleFormation.dynamic(:load_balancer_listeners) do |_name, _config = []|
  _config = [] if _config.nil?

  resources.set!(_name) do
    registry! :default_config, :listeners,
      listeners: []

    registry! :apply_config, :listeners, 
      listeners: _config

    listeners = state!(:listeners)[:listeners].map do |hash|
      value = {}
      value[:Protocol]         = hash[:from_proto] || "tcp"
      value[:LoadBalancerPort] = hash[:from_port]
      value[:InstanceProtocol] = hash[:to_proto] || hash[:from_proto] || "tcp"
      value[:InstancePort]     = hash[:to_port] || hash[:from_port]

      if hash[:certificate]
        value[:PolicyNames] = array!("SSLPolicy")
        value[:SSLCertificateId] = join!(
          "arn:aws:iam::", account_id!, ":server-certificate", "/",
          hash[:certificate]
        )
      end

      value
    end

    properties do
      listeners array!(*listeners)
    end
  end
end





