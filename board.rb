require "./piece.rb"

class Board
  attr_reader :grid
  SIZE = 8

  def grid
    @grid ||= set_grid
  end

  def set_grid
    ([[nil] * 8] * 8).tap do |grid|
      [:black, :white].each do |color|
        back_row, front_row = (color == :black) ? [0,1] : [7,6]

        grid[back_row] = back_row(color, back_row)
        grid[front_row] = pawn_row(color, front_row)
      end
    end
  end

  def back_row(color, row)
    piece_classes = [Rook, Bishop, Knight, King, Queen, Knight, Bishop, Rook]
    piece_classes.reverse! if color == :white

    [].tap do |row_array|
      (0..7).each do |col|
        row_array << piece_classes[col].new(self, [row, col], color)
      end
    end
  end

  def pawn_row(color, row)
    [].tap do |row_array|
      (0..7).each do |col|
        row_array << Pawn.new(self, [row, col], color)
      end
    end
  end

  def set_pieces
    [Rook.new(:black), Bishop.new(:black)]
  end

  def [](pos)
    self.grid[pos.first][pos.last]
  end

  def []=(pos, value)
    self.grid[pos.first][pos.last] = value
  end

  def checkmate?
    # if either kings have no moves, checkmate.
    false
  end
end

Board.new.grid.each { |row| puts row.join(", ")}