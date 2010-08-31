module EM
  module WebSocket
    module Protocol
      module Version76
      
        # generate protocol 76 compatible response headers
        def response
          response = "HTTP/1.1 101 Web Socket Protocol Handshake\r\n"
          response << "Upgrade: WebSocket\r\n"
          response << "Connection: Upgrade\r\n"
          response << "Sec-WebSocket-Origin: #{origin}\r\n"
          response << "Sec-WebSocket-Location: #{scheme}://#{host}#{path}\r\n"
  
          if protocol
            response << "Sec-WebSocket-Protocol: #{protocol}\r\n"
          end

          response << "\r\n"
          response << Digest::MD5.digest(keyset)

          response
        end

        protected
        
        # generate a keyset from the 3 secure keys
        def keyset
          [:sec_websocket_key1,:sec_websocket_key2].collect { |k| 
            partify(@headers[k])
          }.push(@headers[:sec_websocket_key3]).join
        end

        # decode a websocket key and create a token for
        # use in the response
        # +key+ the key value to decode
        def partify key
          nums   = key.scan(/[0-9]/).join.to_i
          spaces = key.scan(/ /).size
  
          raise "Key Error: #{key} has no spaces" if spaces == 0
          raise "Key Error: #{key} nums #{nums} is not an integral multiple of #{spaces}" if (nums % spaces) != 0

          [nums / spaces].pack("N*")
        end
              
      end
    end
  end
end