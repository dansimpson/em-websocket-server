$:.unshift File.dirname(__FILE__) + '/../../lib'

require 'rubygems'
require 'web_socket'
require 'json'
require 'uuid'
require 'pp'

$games   = {}
$waiting = nil
$status  = nil

class StatusChannel < EM::Channel

	def initialize
		super
		@count = 0
	end
	
	def increment
		@count += 1
		push @count
	end
	
	def decrement
		@count -= 1
		push @count
	end
end

class Game < EM::Channel

	attr_accessor :id, :player1, :player2, :current, :grid

	def initialize player1, player2
		super()
		@id 		= UUID.new
		@player1 	= player1
		@player2 	= player2
		@grid 		= Matrix.diagonal(0,0,0)
	end
	
	def set_turn p
		@current = p
		@current.turn!
	end
	
	def start!
		@current = nil
		@player1.start!
		@player2.start!
		toggle
	end
	
	def move p, data
		if @current == p
			unless @matrix[data["x"].to_i][data["y"].to_i]
				@matrix[data["x"].to_i][data["y"].to_i] = p.key
			
				@player1.send_move(p.key, data)
				@player2.send_move(p.key, data)
				
				
				winner  = has_winner?
				full	= full?
				
				if winner || full
					@player1.send_command("game_over")
					@player2.send_command("game_over")
					if winner
						p.send_command("win")
						opponent(p).send_command("loss")
					else full?
						@player1.send_command("draw")
						@player2.send_command("draw")
					end
				else
					toggle
				end
			end
		end
	end

	def full?
		@matrix.each do |row|
			row.each do |col|
				return false unless col
			end
		end
		return true
	end

	def has_winner?
		return true if @matrix[1][1] && (@matrix[0][0] == @matrix[1][1]) && (@matrix[1][1] == @matrix[2][2])
		return true if @matrix[1][1] && (@matrix[0][2] == @matrix[1][1]) && (@matrix[1][1] == @matrix[2][0])
		@matrix.each do |row|
			return true if row[1] && (row[0] == row[1]) && (row[1] == row[2])
		end
		return false
	end

	def opponent p
		@player1 == p ? @player2 : @player1
	end

	def toggle
		set_turn(@current == @player1 ? @player2 : @player1)
	end
end

class TickTackToeServer < WebSocket::Server

	attr_accessor :game_id, :key, :status_key
	
	def on_connect
		@status_key = $status.subscribe do |c|
			send_user_count c
		end
		$status.increment
	end

	def on_disconnect
		$status.unsubscribe @status_key
		$status.decrement
		delete_game!
	end

	def on_receive data

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
					self.key = "X"
					opponent.key = "O"
					self.game_id = opponent.game_id = game.id
					game.start!
					$games[game_id] = game
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

	def delete_game!
		if $games.key?(game_id)
			$games.delete(game_id)
		end
	end
	
	def game
		$games[game_id]
	end

	def turn!
		send_command "turn"
	end

	def game_over!
		delete_game!
		send_command "game_over"
	end
	
	def start!
		send_command "start"
	end
	
	def send_move key, data
		send_message({:msg => "move", :key => key, :data => data}.to_json)
	end

	def send_command cmd
		send_message({:msg => cmd}.to_json)
	end
	
	def send_user_count count
		send_message({:msg => :user_count, :data => count}.to_json)
	end
	
	
	def send_message msg
		super msg
		puts "Sent: #{msg}"
	end
end


EM.epoll
EM.set_descriptor_table_size(10240)

EM.run do
	$waiting  = EM::Queue.new
	$status = StatusChannel.new

	EM.start_server "0.0.0.0", 8000, TickTackToeServer
end