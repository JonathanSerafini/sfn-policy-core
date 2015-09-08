
#
# default_state
#
# Provides a helper method used to set default state attributes without
# overriding existing states.
#
SfnRegistry.register(:default_state) do |_config|
  _config.each do |key, value|
    if value.nil? 
      _arg_state.delete(key)
    elsif state!(key).nil?
      set_state!(key => value)
    end
  end
end

#
# default_config
#
# Provides a helper method used to store configuration attributes
# within a state!(key) hash.
#
SfnRegistry.register(:default_config) do |_name, _config|
  _current_state = state!(_name) || {}

  _config.each do |key, value|
    next if _current_state.key?(key) and not
            _current_state[key].nil? and not
            (_current_state[key].empty? rescue false)
    _current_state[key] = value
  end

  set_state!(_name => _current_state)
end

SfnRegistry.register(:apply_config) do |_name, _config|
  _current_state = state!(_name) || {}

  _config.each do |key, value|
    _current_state[key] = value
  end

  _current_state.delete_if {|k,v| v.nil? }

  set_state!(_name => _current_state)
end

SfnRegistry.register(:resource_config) do |_name, _config={}, _default={}|
  tags = _config.delete(:tags) || {}
  registry! :apply_config, :tags, tags unless tags.empty?
  
  registry! :default_config, _name, _default || {}
  registry! :apply_config, _name, _config || {}
end

SfnRegistry.register(:resource_properties) do |_name|
  properties do
    state!(_name).each do |key, value|
      set!(key, value)
    end
    tags registry! :context_tags if taggable?
  end
end

