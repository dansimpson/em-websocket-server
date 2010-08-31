module EM
  module WebSocket

    class Request

      Path    = /^GET (\/[^\s]*) HTTP\/[\d|\.]+$/.freeze
      Header  = /^([^:]+):\s*(.+)$/.freeze

      # create a new request object
      # +data+ the string value of the HTTP headers for parsing
      def initialize data=nil
        parse(data) if data
      end
    
      # parse the HTTP headers from an incoming
      # request into actionable information
      # +data+ The header data as a string
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
             
      # generate a response for this request
      # may be overridden by other protocol modules
      def response
        response = "HTTP/1.1 101 Web Socket Protocol Handshake\r\n"
        response << "Upgrade: WebSocket\r\n"
        response << "Connection: Upgrade\r\n"
        response << "WebSocket-Origin: #{origin}\r\n"
        response << "WebSocket-Location: #{scheme}://#{host}#{path}\r\n"
        response << "\r\n"
        response
      end  
    
    
      # returns a header value
      # +key+ the symbol value of the header field
      def [](key)
        @headers[key.to_sym]
      end
    
      # sets the header value
      # +key+ the header field name
      # +val+ the value of said field
      def []=(key,val)
        @headers[key.downcase.gsub(/-/,"_").to_sym] = val
      end
    
      # is the websocket connection supplying secure
      # web socket fields in the header
      def is_secure?
        @headers.has_key? :sec_websocket_key1
      end
    
      # the websocket protocol that is used
      def protocol
        @headers[:sec_websocket_protocol]
      end
    
      # the origin domain of the connected client
      def origin
        @headers[:origin]
      end
  
      # the host which the client connected to
      def host
        @headers[:host]
      end
    
      # the request path portion of the request URI
      def path
        @headers[:path]
      end
      
      # the websocket scheme, either ws, or wss for
      # a TLS secured connection
      def scheme
        "ws"
      end
    
    end
  end
end