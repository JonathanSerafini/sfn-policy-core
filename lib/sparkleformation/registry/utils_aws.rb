
require 'aws-sdk-core'

SfnRegistry.register(:available_zones) do |_config|
  state!(:available_zones) ||= begin
    client =  ::Aws::EC2::Client.new
    array =   client.
                describe_availability_zones(filters: [{ 
                  name: :state, 
                  values: ["available"] 
                }]).
                availability_zones.
                map { |object| object.zone_name }.
                sort[0..2]
    set_state!(available_zones: array)
    array
  end
end

