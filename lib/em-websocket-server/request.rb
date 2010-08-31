module EM
  module WebSocket

    class Request

      Path    = /^GET (\/[^\s]*) HTTP\/[\d|\.]+$/.freeze
      Header  = /^([^:]+):\s*(.+)$/.freeze

      def initialize data=nil
        parse(data) if data
      end
    
      def parse data

        lines = data.split("\r\n")
      
        if Path =~ lines.shift
          @headers = {
            :path => $1
          }
        else
          raise "Invalid request: #{data}"
        end
      
        #breaks when we get to the empty line
        while((line = lines.shift) && !line.empty?)
          if Header =~ line
            self[$1] = $2
          else
            raise "Invalid header: #{line}"
          end
        end

        if is_secure?
          if lines.empty?
            raise "Key 3 is required for protocol version 76"
          end
          @headers[:sec_websocket_key3] = lines.last
          extend Protocol::Version76
        end

      end
             
      def response
        response = "HTTP/1.1 101 Web Socket Protocol Handshake\r\n"
        response << "Upgrade: WebSocket\r\n"
        response << "Connection: Upgrade\r\n"
        response << "WebSocket-Origin: #{origin}\r\n"
        response << "WebSocket-Location: #{scheme}://#{host}#{path}\r\n"
        response << "\r\n"
        response
      end  
    
    
      def [](key)
        @headers[key.to_sym]
      end
    
      def []=(key,val)
        @headers[key.downcase.gsub(/-/,"_").to_sym] = val
      end
    
      def is_secure?
        @headers.has_key? :sec_websocket_key1
      end
    
      def protocol
        @headers[:sec_websocket_protocol]
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
      
      def scheme
        "ws"
      end
    
    end
  end
end