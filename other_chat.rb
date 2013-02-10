# require 'eventmachine'
require 'em-http-request'

EventMachine.run do
  puts 'starting get to twitter'
  http = EventMachine::HttpRequest.new('http://www.twitter.com/firehose').get
  http.stream { |chunk| print chunk }
end