
SparkleFormation.build do
  registry! :boostrap
  
  set_state! tier: :public

  available_zones = registry!(:available_zones)
  available_letters = available_zones.map { |az| az[-1] }

  parameters do
    vpc_ssh_security_group_id do
      type "String"
      description "VPC wide ssh security group"
    end

    app_instance.default "m3.large"
    scaling_nodes_desired.default "1"
    scaling_nodes_min.default "1"
    scaling_nodes_max.default "1"
  end

  #
  # Instance Roles
  #
  dynamic! :iam_role, :role,
    managed_policy_arns: array!(ref!(:vpc_scaling_policy))

  dynamic! :iam_policy, :nat_monitor_policy,
    roles: array!(ref!(:role)),
    policies: {
      statement: [
        {
          effect: "Allow",
          resource: "*",
          action: %w(
            ec2:DescribeSubnets
            ec2:DescribeRouteTables
            ec2:CreateRoute
            ec2:ReplaceRoute
            ec2:ModifyInstanceAttribute
          )
        }
      ]
    }

  dynamic! :iam_instance_profile, :nat_profile,
    roles: array!(ref!(:role))

  #
  # Security Group
  #
  dynamic! :security_group, :security_group,
    state: { label: :app },
    ingress_rules: [
      { protocol: :tcp, from_port: 22, source: "0.0.0.0/0" },
      { protocol: "-1", source: ref!(:vpc_security_group_id),
        from_port: 0, to_port: "65535" }
    ]

  #
  # AutoScaling group per AZ
  #
  dynamic! :launch_config, :launch_config,
    security_groups: array!(
      ref!(:vpc_ssh_security_group_id),
      ref!(:vpc_security_group_id),
      ref!(:security_group)
    ),
    iam_instance_profile: ref!(:nat_profile)

  available_letters.count.times do |i|
    az = available_letters[i]
    az_ref = select!(i, ref!(:vpc_availability_zones))
    az_subnet = select!(i, registry!(:context_subnets))

    dynamic! :scaling_group, "scaling_group_#{az}".to_sym,
      metadata: {
        properties: {
          managed_zones: %w(protected private management)
        }
      },
      creation_policy: false,
      update_policy: false,
      scaling_policy: false,
      load_balancer_names:  nil,
      VPC_zone_identifier:  array!(az_subnet),
      availability_zones:   array!(az_ref)
  end
end

