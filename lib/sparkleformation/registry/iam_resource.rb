
SfnRegistry.register(:iam_policies) do |_config|
  _config.map do |name, hash|
    {
      PolicyName: name,
      PolicyDocument: registry!(:policy_document, hash)
    }
  end
end

SfnRegistry.register(:iam_policy_document) do |_config|
  _config[:version] ||= "2012-10-17"
  _config[:statement] ||= []
  _config[:statement] = case _config[:statement]
                        when Array then _config[:statement]
                        else [_config[:statement]]
                        end
  _config[:statement].map! do |hash|
    Hash[hash.map { |k,v| next if v.nil?; [process_key!(k), v] }.compact]
  end
  Hash[_config.map { |k,v| next if v.nil?; [process_key!(k), v] }.compact]
end

