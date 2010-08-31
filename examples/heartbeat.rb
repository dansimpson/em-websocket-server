$:.unshift File.dirname(__FILE__) + "/../lib"

require "rubygems"
require "em-websocket-server"

class HeartBeatServer < EM::WebSocket::Server


  def on_connect
		@sid = Hub.subscribe do |msg|
			send_message msg
		end
    EM::WebSocket::Log.debug "Connected"
  end

	def on_receive msg
	  #do nothing
	end

end

EM.run do
  Hub = EM::Channel.new
	EM.start_server "0.0.0.0", 8000, HeartBeatServer
	EM.add_periodic_timer(5) do
    Hub << Time.now.to_s
  end
end