class Board
  attr_reader :grid
  SIZE = 8

  def initialize(grid = nil)
    @grid = grid if grid
  end

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
    move!(start_pos, end_pos) if valid_move?(start_pos, end_pos)
  end

  def puts_player_in_check?(piece, end_pos)
    duped_board = self.deep_dup
    duped_board.move!(piece.pos, end_pos)
    duped_board.in_check?(piece.color)
  end

  # PIECES ARE MOVING [Y, X] INSTEAD OF [X, Y]
  def move!(start_pos, end_pos)
    piece = self[start_pos]

    piece.pos = end_pos

    self[end_pos] = piece
    self[start_pos] = nil
  end

  def valid_move?(start_pos, end_pos)
    piece = self[start_pos]

    if piece.nil? || !piece.available_moves.include?(end_pos) ||
      puts_player_in_check?(piece, end_pos)
      # We need to catch this exception in the Game class.
      # raise InvalidMoveError.new("INPUT ERROR MESSAGE HERE")
      return false
    end

    piece.available_moves.include?(end_pos)
  end

  def back_row(color, row)
    piece_classes = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

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
      return piece if piece.color == color && piece.is_a?(King)
    end
  end

  def team_moves(color)
    team_pieces(color).map do |piece|
      next if piece.nil?

      if piece.is_a?(King)
        piece.available_moves!
      else
        piece.available_moves
      end
    end.compact.flatten(1)
  end

  def team_pieces(color)
    self.grid.flatten.compact.select {|piece| piece.color == color }
  end

  def checkmate?(color, ending_pos)
    king = self.find_king(color)
    team_escape = team_cant_escape_check?(color, ending_pos)
    in_check?(color) && king.available_moves.empty? && team_escape
  end

  def team_cant_escape_check?(color, ending_pos)
    team_pieces(color).each do |piece|
      possible_moves = piece.available_moves
      possible_moves.each do |move|
        duped_board = self.deep_dup
        duped_board.move!(piece.pos, move)
        return false if !duped_board.in_check?(color)
      end
    end

    true
  end

  def deep_dup
    new_board = Board.new(Array.new(SIZE) { Array.new(SIZE) })
    (team_pieces(:black) + team_pieces(:white)).each do |piece|
      new_board[piece.pos] = piece.dup(new_board)
    end
    new_board
  end
end