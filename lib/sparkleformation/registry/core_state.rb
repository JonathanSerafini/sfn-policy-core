
#
# context_init
#
# Provides the basic state attributes which will be available from all
# resource within this context or template. The values are used as defaults
# and may be overriden as desired in a later context. 
#
# @parameter :env_product
# @parameter :env_revision
# @parameter :env_name
# @parameter :app_name
# @parameter :app_tier
#
# @registry  :default_state
# 
SfnRegistry.register(:core_init) do
  #
  # State attributes mapping back to parameters that describe the stack
  #
  registry! :default_state, 
    product:      ref!(:env_product),   # ex.: cml, wsr, wso, osr, rtl
    revision:     ref!(:env_revision),  # ex.: 2015010101
    environment:  ref!(:env_name),      # ex.: prod, stag, dev
    application:  ref!(:app_name),      # ex.: frontend, rabbitmq, sensu
    tier:         ref!(:app_tier)       # ex.: public, dmz, protected, private

  #
  # State attributes describing the tags that should always be present
  # - Tag attributes are handled by the context_tags registry
  #
  registry! :default_state, 
    tags: {
      product: true,
      environment: true,
      application: true,
      tier: true,
      name: true
    }

  #
  # Declare whether the current context is within an auto_scaling group. This
  # impacts tag generation by ensuring they are set to propagate at launch.
  #
  registry! :default_state, 
    auto_scaling: false

  #
  # Declare all available / supported application tiers which we will support.
  # These will be used when creating the VPC subnets.
  #
  registry! :default_state, 
    application_tiers: %w(public protected private management),
    default_tier:      :protected

end

