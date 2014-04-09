require './board'
require './piece'

class Game
  attr_reader :board, :players

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

      starting_pos, ending_pos = prompt_user(current_player)
      board.move(starting_pos, ending_pos)
      # rescue InvalidMoveError in here
    end until game_over?(current_player)

    display_end_game_message
  end

  def render
    system('clear')

    self.board.grid.each do |row|
      puts row.join(', ')
    end
  end

  def prompt_user(color)
    # debugger
    while
      print "#{color} | What piece would you like to move? "
      start_pos = gets.chomp#.split(',').map(&:to_i)

      start_piece = self.board[start_pos]
      if start_piece.color != color
        puts "That piece is not yours."
        next
      end

      print "#{color} | Where would you like to place the piece? "
      end_pos = gets.chomp.split(',').map(&:to_i)

      if self.board.valid_move?(start_pos, end_pos)
        return [start_pos, end_pos]
      else
        puts "That piece can't go there."
        next
      end
    end
  end

  def game_over?(color)
    self.board.checkmate?(color)
  end
end

Game.new.play

#
# game = Game.new
# board_var = game.board
# pos = [0,0]
# piece = Bishop.new(board_var, pos)
# # game.board[pos] = rook
# p piece.available_moves