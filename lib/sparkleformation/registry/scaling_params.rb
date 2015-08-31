
#
# scaling_params
#
# Provides the basic parameters for autoscaling groups
#
# @registry  :context_init
# 
SfnRegistry.register(:scaling_params) do
  parameters do
    vpc_scaling_sns_id do
      type "String"
      description "SNS Topic ARN for autoscaling events"
    end

    vpc_scaling_policy_id do
      type "String"
      description "Default IAM Policy for autoscaling groups"
    end

    scaling_nodes_min do
      type "Number"
      description "Minimum amount of nodes"
      default "2"
    end

    scaling_nodes_desired do
      type "Number"
      description "Initial amount of nodes"
      default "2"
    end

    scaling_nodes_max do
      type "Number"
      description "Maximum amount of nodes"
      default "3"
    end

    scaling_grace_period do
      type "Number"
      description "Seconds after initialization to start checking health"
      default "300"
    end
    scaling_timeout do
      type "String"
      description "Maximum time (Ns) to wait for scaling startup"
      default "PT10M"
    end

    scaling_cooldown do
      type "Number"
      description "Seconds after a scaling activity is completed"
      default "60"
    end

    scaling_alarm_window do
      type "Number"
      description "Amount of seconds to trigger scale up/down alarm"
      default "240"
    end

    scaling_alarm_cpu_upper do
      type "Number"
      description "Average amount of CPU to trigger scale up"
      default "75"
    end

    scaling_alarm_cpu_lower do
      type "Number"
      description "Average amount of CPU to trigger scale down"
      default "40"
    end

    scaling_termination_max do
      type "Number"
      description "Number of instance that may be terminated at once"
      default "1"
    end

    scaling_nodes_scaled do
      type "Number"
      description "Amount of nodes to increase/decrease during event"
      default "1"
    end
  end
end

