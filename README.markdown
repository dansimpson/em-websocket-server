#em-websocket-server

* em-websocket-server allows the creation of efficient, evented, websocket services

##Installation

	gem install em-websocket-server -s http://gemcutter.org

##Dependencies
- eventmachine http://github.com/eventmachine/eventmachine

##Docs

Not yet... coming soon

##Quick Example

	require 'rubygems'
	require 'web_socket'
	require 'json'

	#create a channel for pub sub
	$chatroom = EM::Channel.new
	
	class ChatServer < WebSocket::Server
	
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
	
##Thanks
sidonath
TheBreeze