
require 'aws-sdk-core'

SfnRegistry.register(:available_zones) do
  result = state!(:available_zones)
  result ||= begin
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

