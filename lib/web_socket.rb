require 'rubygems'
require 'eventmachine'
require 'digest'
require 'pp'

module WebSocket
  VERSION = 0.13
end

require 'web_socket/util.rb'
require 'web_socket/frame.rb'
require 'web_socket/server.rb'
require 'web_socket/client.rb'