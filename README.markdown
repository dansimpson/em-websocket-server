#em-websocket-server

* em-websocket-server allows the creation of efficient, evented, websocket services

##Installation

	gem install em-websocket-server -s http://gemcutter.org

##Dependencies
- eventmachine http://github.com/eventmachine/eventmachine

##Explain
To leverage em-websocket-server, you simply need to extend EM::WebSocket::Server
and register the server with eventmachine.  When a client connects, EventMachine will
create a new instance of your class, and allow your application specific code to be
executed in the context of said instance.

##Methods to override:
  
  #called on exception
  on_error error
  
  #called when a client sends a message
  on_receive msg
  
  #called when a client connects
  on_connect
  
  #called when a client is disconnected
  on_disconnect
  
##Other useful methods

  #send a message
  send_message msg
  
  #close the connection
  unbind

##Macros
macros are used to configure your application server.

  class MySweetHandler < EM::WebSocket::Server
    
    #secure incoming connections
    secure
  
    #secure incoming connections, with given key/cert
    secure {
      :private_key_file => "/path/to/private/key",
      :cert_chain_file => "/path/to/ssl/certificate"
    }
  
    #provide a flash socket policy
    flash_policy "/usr/local/policies/domain.com/crossdomain.xml"    
    
  end


##Quick Example

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

##SSL

  class SecureEchoServer < EM::WebSocket::Server

    #provide cert and key
    secure {
      :private_key_file => "/path/to/private/key",
      :cert_chain_file => "/path/to/ssl/certificate"
    }
    
    ...
  
  end

  EM.run do
  	EM.start_server "0.0.0.0", 443, SecureEchoServer
  end

##Custom Flash Policy

  class FlashyEchoServer < EM::WebSocket::Server
    flash_policy "/usr/local/policies/domain.com/crossdomain.xml"
  end

  EM.run do
  	EM.start_server "0.0.0.0", 8000, FlashyEchoServer
  end


##Todo
  * Testing
  * Better inline documentation
  * Web client library with flash based fallback
	
##Thanks
  * sidonath
  * TheBreeze