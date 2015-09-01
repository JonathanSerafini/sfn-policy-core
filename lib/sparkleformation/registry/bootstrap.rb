
#
# bootstrap
#
# Load required registries that should be present in all templates
#

SfnRegistry.register(:bootstrap) do
  registry! :core_init
  registry! :core_params
end

