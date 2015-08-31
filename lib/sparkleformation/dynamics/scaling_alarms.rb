
#
# scaling_policy
#
# Provides an autoscaling policy which corresponds to an action to take when
# a linked alarm triggers.
#
SparkleFormation.dynamic(:scaling_policy) do |_asg, _type, _config = {}|
  _config = {} if _config.nil?
  _name = "#{_asg}_#{_type}".to_sym

  resources.set!(_name) do
    registry! :default_config, :config,
      adjustment_type: "ChangeInCapacity",
      auto_scaling_group_name: ref!(_asg),
      cooldown: ref!(:scaling_cooldown),
      scaling_adjustmnet: 1

    registry! :apply_config, :config,
      _config

    type "AWS::AutoScaling::ScalingPolicy"

    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
    end
  end
end

#
# Provides a cloudwatch alarm linked to a scaling policy which, when is used
# to trigger the policy.
#
SparkleFormation.dynamic(:scaling_alarm) do |_asg, _type, _metric, _config = {}|
  _config = {} if _config.nil?
  _name = "#{_asg}_#{_metric}_#{_type}".to_sym

  resources.set!(_name) do
    registry! :default_config, :config,
      alarm_actions: nil,
      alarm_description: "#{_asg} #{_type} #{_metric}",
      namespace: "AWS/EC2",
      dimensions: [
        {
          Name: "AutoScalingGroupName",
          Value: ref!(:scaling_group)
        }
      ],
      comparison_operator: nil,
      metric_name: "CPUUtilization",
      statistic: "Average",
      threshold: nil,
      period: 60,
      evaludation_period: 3

    registry! :apply_config, :config,
      _config

    type "AWS::CloudWatch::Alarm"

    properties do
      state!(:config).each do |key, value|
        set!(key, value)
      end
    end
  end
end

