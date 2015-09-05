
SparkleFormation.build do
  registry! :bootstrap
  registry! :core_params
  
  set_state! tier: :public

  parameters do
    cloudtrail_bucket_name do
      type "Number"
      description "Bucket to send cloudtrail messages to"
    end

    cloudtrail_sns_topic do
      type "String"
      description "SNS Topic to send cloudtrail messages to"
      default "none"
    end
  end

  conditions do
    use_sns_topic do
      not! equals!(ref!(:cloudtrail_sns_topic), "none")
    end
  end

  resources do
    cloudtrail do
      type "AWS::CloudTrail::Trail"
      properties do
        include_global_service_events "true"
        s3_bucket_name ref!(:cloudtrail_bucket_name)
        is_logging "true"
        sns_topic_name if!(
          :use_sns_topic, ref!(:cloudtrail_sns_topic), no_value!
        )
      end
    end
  end
end

