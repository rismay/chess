require './board'
require './piece'
require './string'
require 'yaml'

class Game
  attr_accessor :board, :players

  def players
    @players ||= [:white, :black].cycle
  end

  def board
    @board ||= Board.new
  end

  def play
    begin
      current_player = self.players.next
      render

      command = prompt_user(current_player)

      if command[0] == ?l
        load_file
        next
      elsif command[0] == ?s
        save_to_yaml
        break
      end

      starting_pos, ending_pos = command
      board.move(starting_pos, ending_pos)
      # rescue InvalidMoveError in here
    end until game_over?(current_player, ending_pos)

    render
    display_end_game_message
  end

  def display_end_game_message
    puts "Checkmate"
  end

  def render
     # system('clear')

    puts " #{(0..7).to_a.join(' ')}"
    self.board.grid.each_with_index do |row, idx|
      puts "#{idx}#{row.join(' ')}"
    end
    puts
  end

  def prompt_user(color)
    while true
      print "#{color} | What piece would you like to move? "
      command = gets.chomp.split(',')

      return command if command[0] == ?s || command[0] == ?l

      start_pos = command.map(&:to_i)

      start_piece = self.board[start_pos]

      if start_piece.color != color
        puts "That piece is not yours."
        next
      end

      puts "Available moves: #{start_piece.available_moves}"

      print "#{color} | Where would you like to place the piece? "
      end_pos = gets.chomp.split(',').map(&:to_i)

      if self.board.valid_move?(start_pos, end_pos)
        return [start_pos, end_pos]
      else
        if self.board.in_check?(color)
          puts "Get your shit together. You're checked, mate."
        else
          puts "That piece can't go there."
        end
        next
      end
    end
  end

  def game_over?(color, ending_pos)
    other_color = color == :black ? :white : :black
    self.board.checkmate?(other_color, ending_pos) #
  end

  def save_to_yaml
    puts "What would you like to call your file, Mr. Putin: "
    file_name = gets.chomp
    yaml_object = self.board.to_yaml
    File.open("#{file_name}","w") {|f| f.write yaml_object }
  end

  def load_file
    puts "Enter the name of the file, Mr. Putin: "
    self.board = YAML::load_file(gets.chomp)
  end
end

Game.new.play
