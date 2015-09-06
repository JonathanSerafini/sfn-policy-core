
SparkleFormation.dynamic(:metadata) do |_name, _config = {}|
  _config = {} if _config.nil?

  #
  # Extract nested non-standard hashes
  #
  nested_configs = {}
  nested_dynamics = %w(
    properties
    mounts
  )

  nested_dynamics.each do |key|
    nested_configs[key.to_sym] = _config.delete(key.to_sym) || {}
  end

  #
  # Create the resource configuration
  #
  _resource = resources.set!(_name) do
    set_state!(_config.delete(:state) || {})
    registry! :apply_config, :config, _config
  end

  dynamic! :metadata_properties, _name, nested_configs[:properties]
  dynamic! :metadata_mounts, _name, nested_configs[:mounts]

  _resource
end

SparkleFormation.dynamic(:metadata_properties) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    metadata do
      registry! :apply_config, :properties, _config

      _camel_keys_set(:auto_disable)
      state!(:properties).each do |key, value|
        set!("#{key}", value)
      end
      _camel_keys_set(:auto_enable)
    end
  end
end

SparkleFormation.dynamic(:metadata_mounts) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    metadata do
      registry! :apply_config, :mounts, _config

      _camel_keys_set(:auto_disable)
      mounts do
        state!(:mounts).each do |key, value|
          value = case value
                  when String then { mount_point: value }
                  else value
                  end

          set!("#{key}", value)
        end
      end
      _camel_keys_set(:auto_enable)

    end
  end
end

