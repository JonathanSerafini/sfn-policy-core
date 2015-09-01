
require "sfn_policy/core/version"
require "sparkle_formation/sparkle"

gem_root = Gem.loaded_specs['sfn_policy-core'].full_gem_path
srkl_root = File.join(gem_root, 'lib', 'sparkleformation')

SparkleFormation::Sparkle.register! :sfn_policy_core, srkl_root

