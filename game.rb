require './board'
require './piece'

class Game
  attr_reader :board

  def initialize
  end

  def board
    @board ||= Board.new
  end

  def play
    self.board.set_pieces

    until game_over?
      puts "Playing..."
      # rescue InvalidMoveError in here
    end
  end

  def game_over?
    self.board.checkmate?
  end
end

game = Game.new
board_var = game.board
pos = [0,0]
piece = Bishop.new(board_var, pos)
# game.board[pos] = rook
p piece.available_moves