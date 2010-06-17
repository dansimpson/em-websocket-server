module WebSocket

  class Server < EM::Connection
  
    @@logger      = nil
    @@num_connections  = 0
    @@callbacks     = {}
    @@accepted_origins  = []
  
    attr_accessor  :connected,
            :headers
  
    def initialize *args
      super
      @connected = false
      @protocol_version = 75
    end
  
    def valid_origin?
      @@accepted_origins.empty? || @@accepted_origins.include?(origin)
    end
  
    #not doing anything with this yet
    def valid_path?
      true
    end
  
    def valid_upgrade?
      @headers[:upgrade] =~ /websocket/i
    end
  
    def origin
      @headers[:origin]
    end
  
    def host
      @headers[:host]
    end
    
    def path
      @headers[:path]
    end
    
    def cookies
      @headers[:cookie]
    end
    
    def protocol
      @headers[:protocol]
    end

    def self.path name, &block
      @@callbacks[name] = block
    end
  
    #tcp connection established
    def post_init
      @@num_connections += 1
    end
  
    #must be public for em
    def unbind
      @@num_connections -= 1
      on_disconnect
    end

    def send_message msg
      send_data Frame.encode(msg)
    end

    protected

    #override this method
    def on_receive msg
      log msg
    end
  
    #override this method
    def on_connect
      log "connected"
    end
  
    #override this method
    def on_disconnect
      log "disconnected"
    end
  
    def log msg
      if @@logger
        @@logger.info msg
      else
        puts msg
      end
    end
  
    private
  
    # when the connection receives data from the client
    # we either handshake or handle the message at 
    # the app layer
    def receive_data data
      unless @connected
        handshake data
      else
        while msg = data.slice!(/\000([^\377]*)\377/)
          on_receive Frame.decode(msg)
        end
      end
    end
  
    # parse the headers, validate the origin and path
    # and respond with appropiate headers for a 
    # healthy relationship with the client
    def handshake data
      #convert the headers to a hash
      @headers, challenge = Util.parse_headers(data)

      if challenge
        @protocol_version = 76
        
        key1 = @headers[:'sec-websocket-key1']
        key2 = @headers[:'sec-websocket-key2']
        
        part1 = number_from_key(key1)
        part2 = number_from_key(key2)

        unless part1 && part2
          close_connection
          return
        end
        
        buffer = []
        buffer += big_endian_bytes(part1)
        buffer += big_endian_bytes(part2)
        buffer += challenge.bytes.to_a

        md5 = Digest::MD5.new
        hash = md5.digest(buffer.pack('c*'))
      end
      
      # close the connection if the connection
      # originates from an invalid source
      close_connection unless valid_origin?
  
      # close the connection if a callback
      # is not registered for the path
      close_connection unless valid_path?
  
      # don't respond to non-websocket HTTP requests
      close_connection unless valid_upgrade?
  
      #complete the handshake
      send_headers(hash)
  
      @connected = true
  
      on_connect
    end
  
    # send the handshake response headers to
    # complete the initial com
    def send_headers(hash)
      response = "HTTP/1.1 101 Web Socket Protocol Handshake\r\n"
      response << "Upgrade: WebSocket\r\n"
      response << "Connection: Upgrade\r\n"
      if @protocol_version > 75
        response << "Sec-WebSocket-Origin: #{origin}\r\n"
        response << "Sec-WebSocket-Location: ws://#{host}#{path}\r\n"
        response << "Sec-WebSocket-protocol: ws://#{host}#{path}\r\n"
      else
        response << "WebSocket-Origin: #{origin}\r\n"
        response << "WebSocket-Location: ws://#{host}#{path}\r\n"
      end
      response << "\r\n"
      response << hash if @protocol_version > 75
        

      send_data response
    end
    
    def number_from_key(key)
      digits = key.scan(/\d+/).join.to_i
      spaces = key.scan(/\s+/).join.length
      
      if spaces > 0
        return digits / spaces
      else
        return nil
      end
    end
    
    def big_endian_bytes(num)
      bytes = []
      4.times do
        bytes.unshift(num & 0xff)
        num >>= 8
      end
      bytes
    end
  end

end