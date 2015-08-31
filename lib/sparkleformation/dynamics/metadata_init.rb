
SparkleFormation.dynamic(:metadata_init_sets) do |_name, _config = {}|
  _config = {} if _config.nil?

  resources.set!(_name) do
    metadata do
      registry! :apply_config, :configsets, _config

      _camel_keys_set(:auto_disable)
      set!("AWS::CloudFormation::Init") do
        set!("configSets") do
          state!(:configsets).each do |name, array|
            set!("#{name}", array)
          end
        end
      end
      _camel_keys_set(:auto_enable)

    end
  end
end

SparkleFormation.dynamic(:metadata_init_set) do |_name, _set, _config = {}|
  _config = {} if _config.nil?

  _config.each do |type, hash|
    dynamic! :metadata_init_item, _name, _set, type, hash
  end
end

SparkleFormation.dynamic(:metadata_init_item) do |_name, _set, _type, _config|
  resources.set!(_name) do
    metadata do
      _camel_keys_set(:auto_disable)
      set!("AWS::CloudFormation::Init") do
        set!("#{_set}") do
          set!("#{_type}") do 
            _config.each do |name, hash|
              set!("#{name}", hash)
            end
          end
        end
      end
    end
  end
end

