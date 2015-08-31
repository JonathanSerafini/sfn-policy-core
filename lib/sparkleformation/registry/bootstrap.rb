
#
# bootstrap
#
# Load required registries that should be present in all templates
#

SfnRegistry.register(:bootstrap) do
  registry! :context_init
  registry! :context_params
end

