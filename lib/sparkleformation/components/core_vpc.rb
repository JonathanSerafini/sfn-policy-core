
SparkleFormation.build do
  registry! :bootstrap
  registry! :core_params

  available_zones = registry!(:available_zones)
  available_letters = available_zones.map { |az| az[-1] }

  #
  # Parameters
  #
  parameters do
    vpc_cidr_prefix do
      type "String"
      description "First two octets of subnet CIDR: 10.xx.0.0/16"
      allowed_pattern "10.\\d\\d"
    end

    vpc_dns_hostnames do
      type "String"
      default "true"
      allowed_values %w(true false)
    end

    vpc_dns_support do
      type "String"
      default "true"
      allowed_values %w(true false)
    end

    vpc_tenancy do
      type "String"
      default "default"
    end

    vpc_domain_name do
      type "String"
    end
  end

  #
  # Parameter Outputs
  #
  outputs do
    env_product do
      value ref!(:env_product)
    end

    env_name do
      value ref!(:env_name)
    end

    vpc_domain_name do
      value ref!(:vpc_domain_name)
    end
  end

  #
  # VPC Core
  #
  resources.vpc do
    type "AWS::EC2::VPC"
    properties do
      cidr_block            join!(ref!(:vpc_cidr_prefix), ".", "0.0/16")
      enable_dns_support    ref!(:vpc_dns_support)
      enable_dns_hostnames  ref!(:vpc_dns_hostnames)
      instance_tenancy      ref!(:vpc_tenancy)
      tags                  registry!(:context_tags)
    end
  end

  resources.dhcp_options do
    type "AWS::EC2::DHCPOptions"
    properties do
      domain_name         "ec2.internal"
      domain_name_servers ["AmazonProvidedDNS"]
      tags registry!(:context_tags)
    end
  end

  resources.dhcp_options_associtation do
    type "AWS::EC2::VPCDHCPOptionsAssociation"
    properties do
      dhcp_options_id ref!(:dhcp_options)
      vpc_id ref!(:vpc)
    end
  end

  resources.internet_gateway do
    type "AWS::EC2::InternetGateway"
    properties do
      tags registry!(:context_tags)
    end
  end

  resources.internet_gateway_attach do
    type "AWS::EC2::VPCGatewayAttachment"
    properties do
      internet_gateway_id ref!(:internet_gateway)
      vpc_id ref!(:vpc)
    end
  end

  outputs.vpc_gateway_id do
    value ref!(:internet_gateway)
  end

  #
  # VPC Network
  #
  cidr_az_offset = 0

  available_letters.each do |az|
    cidr_tier_offset = 0 

    state!(:application_tiers).each do |tier|
      cidr_subnet_offset = cidr_az_offset + cidr_tier_offset

      subnet_routes = {}
      subnet_routes = {
        default: {
          destination_cidr_block: "0.0.0.0/0",
          gateway_id: ref!(:internet_gateway)
        }
      } if tier == "public"

      dynamic! :subnet, tier, az,
        vpc_id: ref!(:vpc),
        cidr_suffix: "#{cidr_subnet_offset}.0/24",
        routes: subnet_routes

      cidr_tier_offset += 1
    end

    cidr_az_offset += 64
  end

  outputs.vpc_availability_zones do
    set!("Value", { "Fn::Join" => [",", available_zones ]})
  end

  #
  # DNS Hosted Zone
  #
  resources.hosted_zone do
    type "AWS::Route53::HostedZone"
    properties do
      name ref!(:vpc_domain_name)
      hosted_zone_tags registry!(:context_tags)
    end
  end

  outputs.vpc_domain_id do
    value ref!(:hosted_zone)
  end

  #
  # IAM Policies
  #
  dynamic! :iam_role, :vpc_default_role
  dynamic! :iam_instance_profile, :vpc_default_profile,
    roles: array!(ref!(:vpc_default_role))

  dynamic! :iam_managed_policy, :vpc_scaling_policy,
    description: "CFNChefIntegration",
    roles: array!(ref!(:vpc_default_role)),
    policy_document: {
      statement: [
        { effect: "Allow", resource: "*",
          action: %w(cloudformation:SignalResource) },
        { effect: "Allow", resource: "*",
          action: %w(cloudformation:DescribeStackResource) },
        { effect: "Allow", resource: "*",
          action: %w(ec2:DescribeInstances) }
      ]
    }

  #
  # Security Groups
  #
  dynamic! :security_group, :vpc_ssh_security_group,
    state: { label: :ssh },
    vpc_id: ref!(:vpc)

  dynamic! :security_group, :vpc_security_group,
    vpc_id: ref!(:vpc),
    ingress_rules: [
      { from_port: 22, source: ref!(:vpc_ssh_security_group) }
    ]

  #
  # AutoScaling notifications
  #
  resources.autoscaling_topic do
    type "AWS::SNS::Topic"
    properties do
      display_name "autoscaling"
      topic_name "autoscaling"
    end
  end

  outputs.vpc_autoscaling_sns_id do
    value ref!(:autoscaling_topic)
  end

  #
  # AutoScaling Lambda
  #
  dynamic! :iam_role, :vpc_scaling_record,
    principal: { Service: "lambda.amazonaws.com" },
    managed_policy_arns: %w(
      arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
      arn:aws:iam::aws:policy/AmazonRoute53FullAccess
      arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    )

end

