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

      # do not override!
      def post_init
        start_tls(self.class.tls_opts) if self.class.secure?
      end

      # close the connection
      def unbind
        on_disconnect
      end

      # send a message to the websocket client
      # +msg+ the message the client should receive
      def send_message msg
        send_data "\x00#{msg}\xff"
      end

      protected

      # override
      def on_receive msg
      end
  
      # override this method
      def on_connect
      end
  
      # override this method
      def on_disconnect
      end
      
      # override this method
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
            Log.debug "Sending flash policy #{self.class.policy_content}"
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

        # set the flash policy this is sent to flash clients
        # +policy+ either a string containing XML or a
        # path to a XML policy file
        def flash_policy policy
          if policy =~ /\.xml$/
              @policy = File.read(policy)
          else
              @policy = policy
          end
        end
        
        # get the flash policy content
        def policy_content
          @policy || default_policy
        end
        
        # secure any instance of this connection
        # with TLS
        # +opts+ the EM specific options hash for starting
        # tls on the connection.  Important options:
        # :private_key_file
        # :cert_chain_file
        def secure opts={}
          @tls_opts = opts
        end
      
        # is the connection secured with TLS?
        def secure?
          @tls_opts != nil
        end
      
        # the TLS options used for the secured connection
        def tls_opts
          @tls_opts
        end
      
        # add a domain to the list of allowable domains
        # +domain+ the domain that is allowed eg: cnet.com
        def accept_domain domain
          @accepted = [] unless @accepted
          @accepted << domain
        end
      
        # the set of domains that the server should
        # accept the connection from.  If the list is
        # empty, the server will accept all connections
        def accept_domains
          @accepted || []
        end
        
        # the default flash policy content, which accepts
        # from all domains to all ports (maybe not a good thing)
        def default_policy
          "<?xml version=\"1.0\"?><cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>"
        end
            
      end
    end
  end
end