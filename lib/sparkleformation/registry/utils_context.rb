
#
# context_name
#
# Provides a name composed of the stack's product, environment and application
# as well as an optional label. This will be used to generate the Name tag
# as well as to provide descriptions for some resources.
# 
# @registry   :context_init
#
SfnRegistry.register(:context_name) do |_label = nil|
  _label ||= state!(:label)
  _label = [_label]

  join!(
    *array!(state!(:product), state!(:environment), state!(:application)).
     concat(_label).
     compact,
    { options: { delimiter: '-' } }
  )
end

#
# context_tags
#
# Provides resource tags based upon the currently defined state of the context.
#
# @registry   :context_init
# @registry   :context_name
#
SfnRegistry.register(:context_tags) do |_config = {}|
  _auto_scaling = state!(:auto_scaling)
  _config = {} if _config.nil?
  _data = {}

  #
  # The tags state is a hash where the names are the Tag name desired and the
  # value may be one of : 
  # - true    : the tag value is the state! matching the key name
  # - Symbol  : the tag value is the state! matching the value symbol
  # - false   : do not create this tag
  # - value   : the tag value is the provided value
  #
  state!(:tags).each do |key, value|
    _data[key] = case value
                 when true then
                   if key == "name" then registry!(:context_name)
                   else state!(key)
                   end
                 when Symbol then state!(value)
                 when false then nil
                 else value
                 end
  end

  # 
  # Optionally merge in and override the state tags with the supplied hash
  #
  _data.merge!(_config)

  #
  # Convert the hash into an array of tags useable by cloudformation
  #
  array!(*_data.map do |key, value|
    next if value.nil?
    _value = {
      Key: process_key!(key),
      Value: value
    }
    _value[:PropagateAtLaunch] = true if _auto_scaling
    _value
  end.compact)
end

#
# context_subnets
#
# Provides the subnet parameter reference for a resource in a given tier
#
# @parameter  :vpc_#{tier}_subnet_ids
# @registry   :context_init
#
SfnRegistry.register(:context_subnets) do |_tier = nil|
  _tier ||= state!(:tier)

  ref!("vpc_#{_tier}_subnet_ids".to_sym)
end

