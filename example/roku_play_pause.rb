require 'ssdp'
require 'net/http'

finder = SSDP::Consumer.new :timeout => 3, :first_only => true

result = finder.search :service => 'roku:ecp'
if result.nil?
  puts "Couldn't find a Roku device (they are known to frequently stop respoding to SSDP requests...)."
else
  location = result[:params]['LOCATION']
  puts "Roku device found at #{location}, sending play/pause."

  components = /^[Hh][Tt][Tt][Pp]:\/\/([0-9\.]+):([0-9]+)\/$/.match location
  fail "Failed parsing location \"#{location}\"." if components.nil?

  http = Net::HTTP.new components[1], components[2]
  http.post '/keypress/Play', nil
end
