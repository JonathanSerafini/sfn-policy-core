
#
# scaling_creation_policy
#
# Provides an autoscaling group creation policy which will require that
# instances within the stack return COUNT cfn-signal messages before the
# resource creation is considered complete.
#
# Ref: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-product-attribute-reference.html
#
SparkleFormation.dynamic(:scaling_creation_policy) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    registry! :default_config, :creation_policy,
      timeout: ref!(:scaling_timeout),
      count: 1

    registry! :apply_config, :creation_policy, 
      _config

    creation_policy do
      resource_signal do
        state!(:creation_policy).each do |key, value|
          set!(key, value)
        end
      end
    end
  end
end

#
# scaling_update_policy
#
# Provides an autoscaling group update policy which will determine how
# the stack responds to rolling or scheduled updates.
#
# Ref: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-product-attribute-reference.html
#
# TODO : wait_on_resource_signals should be activated, however we need to
#        ensure that nodes are correctly polling for stack updates first
#
SparkleFormation.dynamic(:scaling_update_policy) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    registry! :default_config, :update_policy,
      min_instances_in_service: ref!(:scaling_nodes_min),
      max_batch_size: ref!(:scaling_termination_max),
      pause_time: "PT1M",
      suspend_processes: nil,
      wait_on_resource_signals: false

    registry! :apply_config, :update_policy,
      _config

    update_policy do
      auto_scaling_rolling_update do
        state!(:update_policy).each do |key, value|
          set!(key, value)
        end
      end
    end
  end
end

#
# scaling_deletion_policy
#
# Provides an autoscaling group deletion policy which will determine how
# the stack responds to instance deletions.
#
# Ref: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-product-attribute-reference.html
#
SparkleFormation.dynamic(:scaling_deletion_policy) do |_name, _config = {}|
  # TODO
end

#
# scaling_policies
#
# Provides an autoscaling group with scale-out and scale-in policies as well
# as their corresponding cloudwatch alarms. 
#
SparkleFormation.dynamic(:scaling_default_policies) do |_asg, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_asg) do
    registry! :default_config, :scaling_policies,
      window: ref!(:scaling_alarm_window),
      cooldown: ref!(:scaling_cooldown),
      adjustment: ref!(:scaling_nodes_scaled),
      threshold_upper: ref!(:scaling_alarm_cpu_upper),
      threshold_lower: ref!(:scaling_alarm_cpu_lower)

    registry! :apply_config, :scaling_policies, 
      _config

    _config = state!(:scaling_policies)
  end

  dynamic! :scaling_policy, _asg, "up", 
    scaling_adjustment: _config[:adjustment],
    cooldown: _config[:cooldown]

  dynamic! :scaling_alarm, _asg, "up", "cpu", 
    comparison_operator: "GreaterThanThreshold",
    threshold: _config[:threshold_upper],
    period: _config[:window],
    alarm_actions: array!(ref!("#{_asg}_up".to_sym))

  dynamic! :scaling_policy, _asg, "down", 
    scaling_adjustment: -1,
    cooldown: _config[:cooldown]

  dynamic! :scaling_alarm, _asg, "down", "cpu",
    comparison_operator: "LessThanThreshold",
    threshold: _config[:threshold_lower],
    period: _config[:window],
    alarm_actions: array!(ref!("#{_asg}_down".to_sym))
end

