$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'em-websocket-server'
require 'json'
require 'uuid'

$games   = {}
$waiting = nil

class Game < EM::Channel

	attr_accessor :id, :p1, :p2, :current

	def initialize p1, p2
		super()
		@id = UUID.new
		@p1 = p1
		@p2 = p2
	end
	
	def set_turn p
		@current = p
		@current.turn!
	end
	
	def start!
		@current = nil
		toggle
	end
	
	def move p, data
		if @current == p
			c = @p1 == p ? "x" : "o"
			@p1.send_move(c, data)
			@p2.send_move(c, data)
			toggle
		end
	end

	def toggle
		set_turn(@current == @p1 ? @p2 : @p1)
	end
end

class TickTackToeServer < WebSocketServer

	attr_accessor :game_id
	
	def on_connect
	end

	def on_disconnect
		if $games.key?(game_id)
			$games.delete!(game_id)
		end
	end

	def on_receive data

		puts data
		
		begin
			msg = JSON.parse(data)
		rescue
			send_command "error"
			return
		end

		case msg["msg"]
		when "join"
			if $waiting.empty?
				$waiting.push(self)
				send_command "queued"
			else
				$waiting.pop do |opponent|
					game = Game.new(self, opponent)
					self.game_id = opponent.game_id = game.id
					game.start!
				end
			end
		when "move"
			if game
				game.move self, msg["data"]
				
			else
				log "Cannot move on a nil game!"
			end
		end
	end

	def game
		$games[game_id]
	end

	def turn!
		send_command "turn"
	end

	def game_over!
		send_command "game_over"
	end
	
	def start!
		send_command "start"
	end
	
	def send_move key, data
	
	end

	def send_command cmd
		send_message({:msg => cmd}.to_json)
	end
end


EM.epoll
EM.set_descriptor_table_size(10240)

EM.run do
	$waiting = EM::Queue.new
	EM.start_server "0.0.0.0", 8000, TickTackToeServer
end