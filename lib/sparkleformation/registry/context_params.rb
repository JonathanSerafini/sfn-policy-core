
#
# context_params
#
# Provides the basic parameters that ought to be present on all managed stacks
#
# @registry  :context_init
# 
SfnRegistry.register(:context_params) do
  parameters do
    env_product do
      type "String"
      description "Stack product name ex.: cml, wsr, wso, osr, rtl, cld"
    end

    env_name do
      type "String"
      description "Stack product environment ex.: prod, stag, dev"
    end

    env_revision do
      type "String"
      description "Stack version or revision"
      default ::Time.new.strftime("%Y%m%d%H%M%S")
    end

    app_name do
      type "String"
      description "Stack application name ex.: frontend, backend, api"
    end

    app_tier do
      type "String"
      description "Stack application tier ex.: public, producted, private"
      default state!(:default_tier)
    end
  end
end

