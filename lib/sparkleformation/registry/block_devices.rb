
SfnRegistry.register(:block_mapping) do |_config|
  _config = _config.dup
  _config[:device_name]   ||= nil
  _config[:no_device]     ||= nil
  _config[:virtual_name]  ||= nil
  _config[:ebs] = registry!(:block_ebs, _config[:ebs]) if _config[:ebs]

  Hash[_config.delete_if{|k,v|v.nil?}.map{|k,v| [process_key!(k),v]}]
end

SfnRegistry.register(:block_ebs) do |_config|
  _config = _config.dup
  _config[:delete_on_termination] ||= false
  _config[:snapshot_id] ||= nil
  _config[:iops]        ||= nil
  _config[:volume_size] ||= nil
  _config[:volume_type] ||= "gp2"

  Hash[_config.delete_if{|k,v|v.nil?}.map{|k,v| [process_key!(k),v]}]
end

