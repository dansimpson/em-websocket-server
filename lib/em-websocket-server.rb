require "rubygems"
require "eventmachine"
require "logger"
require "digest"

module EM
  module WebSocket
    Version = 0.50
    Log     = Logger.new STDOUT
  end
end

require "em-websocket-server/server.rb"
require "em-websocket-server/request.rb"
require "em-websocket-server/protocol/version76.rb"
