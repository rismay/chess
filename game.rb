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
    until game_over?
      puts "Playing..."
    end
  end

  def game_over?
    self.board.checkmate?
  end
end

game = Game.new
game.play