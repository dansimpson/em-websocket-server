#em-websocket-server

* em-websocket-server allows the creation of efficient, evented, websocket services

##Installation

If you don't have gemcutter

	gem install gemcutter
	gem tumble

Otherwise

	gem install em-websocket-server

Or

	gem install em-websocket-server -s http://gemcutter.org

##Dependencies
- eventmachine http://github.com/eventmachine/eventmachine

##Docs

Not yet... coming soon

##Quick Example

	require 'rubygems'
	require 'em-websocket-server'
	require 'json'

	#create a channel for pub sub
	$chatroom = EM::Channel.new
	
	class ChatServer < WebSocketServer
	
		#subscribe to the channel on client connect
		def on_connect
			@sid = $chatroom.subscribe do |msg|
				send_message msg
			end
		end
		
		#unsubscribe on client disconnect
		def on_disconnect
			$chatroom.unsubscribe(@sid)
		end
		
		#publish the message to the channel on
		#client message received
		def on_receive msg
			$chatroom.push msg
		end
	
	end
	
	#start the event machine on port 8000 and have
	#it instantiate ChatServer objects for each
	#client connection
	EM.run do
		EM.start_server "0.0.0.0", 8000, ChatServer
	end