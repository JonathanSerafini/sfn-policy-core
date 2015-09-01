
#
# security_group
#
# Creates a EC2 Security Group
#
SparkleFormation.dynamic(:security_group) do |_name, _config = {}|
  _config = {} if _config.nil?

  #
  # Extract nested non-standard hashes
  #
  nested_configs = {}
  nested_dynamics = %w(
    ingress_rules
    egress_rules
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

  #
  # Create the resource configuration
  #
  resources.set!(_name) do
    set_state!(nested_configs[:state])

    registry! :default_config, :config,
      vpc_id: ref!(:vpc_id),
      group_description: registry!(:context_name)
  
    registry! :apply_config, :tags,
      nested_configs[:tags]

    registry! :apply_config, :config,
      _config
  end

  #
  # Create the nested resources
  #
  dynamic! :security_group_rules, _name, :ingress, 
    nested_configs[:ingress_rules]

  dynamic! :security_group_rules, _name, :egress,
    nested_configs[:egress_rules]

  #
  # Create the resources
  #
  resources.set!(_name) do
    type "AWS::EC2::SecurityGroup"
    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
      tags registry!(:context_tags)
    end
  end
end

#
# security_group_rules
#
# Creates a EC2 security group rule set
#
SparkleFormation.dynamic(:security_group_rules) do |_name, _type, _rules = []|
  resources.set!(_name) do
    registry! :apply_config, _type, _type => _rules
      
    _rules = state!(_type)[_type].map do |rule|
      rule[:ip_protocol] ||= "tcp"
      rule[:to_port] ||= rule[:from_port]
      rule[:source] ||= if state!(:tier) == :public
                        then "0.0.0.0/0"
                        else ref!(:vpc_security_group_id)
                        end

      source_key = if rule[:source] =~ /\d+\.\d+\.\d+\.\d+\/\d+/ then :CidrIp
                   elsif _type == :ingress then :SourceSecurityGroupId
                   else :DestinationSecurityGroupId
                   end


      rule[source_key] = rule.delete(:source)
      Hash[rule.map { |k,v| [process_key!(k),v] }]
    end

    properties do
      set!("security_group_#{_type}", array!(*_rules))
    end
  end
end

