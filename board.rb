require "./piece.rb"

class Board
  attr_reader :grid
  SIZE = 8

  def grid
    @grid ||= Array.new(SIZE) { Array.new(SIZE) }.tap do |grid|
      [:black, :white].each do |color|
        back_index, front_index = (color == :black) ? [0,1] : [7,6]

        grid[back_index] = back_row(color, back_index)
        grid[front_index] = pawn_row(color, front_index)
      end
    end
  end

  def move(start_pos, end_pos)
    if valid_move?(start_pos, end_pos)
      piece = self[start_pos]

      piece.pos = end_pos

      self[end_pos] = piece
      self[start_pos] = nil
    end
  end

  def valid_move?(start_pos, end_pos)
    x, y = start_pos
    piece = self.grid[x][y]

    # fix this conditional for exceptions
    if piece.nil? || !piece.available_moves.include?(end_pos)
      # raise "No piece at that location."
      raise "Invalid move."
      return false
    end

    piece.available_moves.include?(end_pos)
  end

  def back_row(color, row)
    piece_classes = [Rook, Bishop, Knight, King, Queen, Knight, Bishop, Rook]
    piece_classes.reverse! if color == :white

    [].tap do |row_array|
      (0...SIZE).each do |col|
        row_array << piece_classes[col].new(self, [row, col], color)
      end
    end
  end

  def pawn_row(color, row)
    [].tap do |row_array|
      (0...SIZE).each do |col|
        row_array << Pawn.new(self, [row, col], color)
      end
    end
  end

  def [](pos)
    self.grid[pos.first][pos.last]
  end

  def []=(pos, value)
    self.grid[pos.first][pos.last] = value
  end

  def in_check?(color)
    other_moves = team_moves(color == :black ? :white : :black)
    other_moves.include?(find_king(color).pos)
  end

  def find_king(color)
    self.grid.flatten.compact.each do |piece|
      return piece if piece.color == color && piece.class.is_a?(King)
    end
  end

  def team_moves(color)
    team_pieces(color).map { |piece| piece.available_moves }.flatten(1)
  end

  def team_pieces(color)
    self.grid.flatten.compact.select {|piece| piece.color == color }
  end

  def checkmate?
    # if either kings have no moves, checkmate.
    false
  end

  def deep_dup
    new_board = Board.new
    (team_pieces(:black) + team_pieces(:white)).each do |piece|
      new_board[piece.pos] = piece.dup(new_board)
    end
    new_board
  end
end

chess_board = Board.new
puts
chess_board.grid.each { |row| puts row.join(", ")}
# p chess_board.valid_move?([0,2],[2,1])
chess_board.move([0,2], [2,3])
puts "Duped:"
chess_board.deep_dup.grid.each { |row| puts row.join(", ")}
puts "Original:"
chess_board.move([2,3], [0,2])
chess_board.grid.each { |row| puts row.join(", ")}
# chess_board.move([7,2],[5,1])
# puts
# chess_board.grid.each { |row| puts row.join(", ")}
# p chess_board.grid