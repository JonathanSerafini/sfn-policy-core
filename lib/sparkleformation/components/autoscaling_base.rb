
SparkleFormation.build do
  registry! :bootstrap
  registry! :instance_params
  registry! :scaling_params

  parameters do
    security_group_elb_id do
      type "String"
      description "Load Balancer security group"
    end

    load_balancer_id do
      type "String"
      description "Load Balancer Id"
    end
  end

  dynamic! :security_group, :security_group,
    state: { label: :app }

  dynamic! :launch_config, :launch_config
  dynamic! :scaling_group, :scaling_group
end

