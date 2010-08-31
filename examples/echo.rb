$:.unshift File.dirname(__FILE__) + "/../lib"

require "rubygems"
require "em-websocket-server"

class EchoServer < EM::WebSocket::Server


  def on_connect
    EM::WebSocket::Log.debug "Connected"
  end

	def on_receive msg
	  send_message msg
	end

end

EM.run do
	EM.start_server "0.0.0.0", 8000, EchoServer
end