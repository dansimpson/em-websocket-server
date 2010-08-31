module EM
  module WebSocket
    class Server < EM::Connection
  
      Pack  = /\000([^\377]*)\377/.freeze
      Frame = /^[\x00]|[\xff]$/.freeze
  
      attr_accessor :connected, :request
  
      def initialize *args
        super
        @request   = nil
        @buffer    = ""
        @connected = false
      end

      def post_init
        start_tls(self.class.tls_opts) if self.class.secure?
      end
  
      def unbind
        on_disconnect
      end

      def send_message msg
        send_data "\x00#{msg}\xff"
      end

      protected

      #override this method
      def on_receive msg
      end
  
      #override this method
      def on_connect
      end
  
      #override this method
      def on_disconnect
      end
      
      #override this method
      def on_error ex
        Log.fatal ex
      end
  
      private
  
      # called when the web socket connection
      # is fully ready
      def on_ready
        @connected = true
        on_connect
      end
  
      # when the connection receives data from the client
      # we either handshake or handle the message at 
      # the app layer
      def receive_data data
        
        if @connected
          #parse each frame and dispatch
          while msg = data.slice!(Pack)
            on_receive msg.gsub(Frame, "")
          end
        else        
          if data =~ /</
            Log.debug "Sending flash policy #{self.class.policy}"
            send_data self.class.policy
            close_connection_after_writing
          else
            handshake data
          end
        end
      end
  
      # parse the request, validate the origin and path
      # and respond with appropiate headers for a 
      # healthy relationship with the client
      def handshake data
        begin
          @request = Request.new(data)
          send_data @request.response
          on_ready
        rescue Exception => ex
          on_error ex
          close_connection
        end
      end
    
      class << self

        def flash_policy policy
          if policy =~ /\.xml$/
              @policy = File.read(policy)
          else
              @policy = policy
          end
        end
        
        def policy
          @policy || default_policy
        end
        
        def secure opts={}
          @tls_opts = opts
        end
      
        def secure?
          @tls_opts != nil
        end
      
        def tls_opts
          @tls_opts
        end
      
        def accept_domain domain
          @accepted = [] unless @accepted
          @accepted << domain
        end
      
        def accept_domains
          @accepted || []
        end
        
        def default_policy
          "<?xml version=\"1.0\"?><cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>"
        end
            
      end
    end
  end
end