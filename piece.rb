class Piece
  attr_accessor :board, :pos, :color

  def initialize(board, pos, color)
    self.board, self.pos, self.color = board, pos, color
  end

  def available_moves
    raise NotImplementedError
  end

  def deltas
    raise NotImplementedError
  end

  def other_team_color
    self.color == :black ? :white : :black
  end

  def enemy?(enemy)
    self.color != enemy.color
  end

  def in_board?(pos)
    pos.first.between?(0,7) && pos.last.between?(0,7)
  end

  def dup(board)
    self.class.new(board, self.pos.dup, self.color)
  end
end

class SlidingPiece < Piece
  DELTA_T = [[1,0],[0,1],[0,-1],[-1,0]]
  DELTA_X = [[1,1],[1,-1],[-1,1],[-1,-1]]

  def available_moves
    [].tap do |moves_array|

      self.deltas.each do |dx, dy|
        new_pos = self.pos

        obstructed = false
        until obstructed
          new_pos = [new_pos.first + dx, new_pos.last + dy]

          if in_board?(new_pos)
            piece = self.board[new_pos]

            if piece.nil?
              moves_array << new_pos
            elsif enemy?(piece)
              obstructed = true
              moves_array << new_pos
            else
              obstructed = true
            end
          else
            obstructed = true
          end
        end
      end
    end
  end
end

class Rook < SlidingPiece
  def deltas
    SlidingPiece::DELTA_T
  end

  def to_s
    self.color == :black ? "\u265C".brown : "\u2656".gray
  end
end

class Bishop < SlidingPiece
  def deltas
    SlidingPiece::DELTA_X
  end

  def to_s
    self.color == :black ? "\u265D".brown : "\u2657".gray
  end
end

class Queen < SlidingPiece
  def deltas
    SlidingPiece::DELTA_T + SlidingPiece::DELTA_X
  end

  def to_s
    self.color == :black ? "\u265B".brown : "\u2655".gray
  end
end

class SteppingPiece < Piece
  DELTA_KI = [[1, 1], [1, -1], [-1, 1], [0, 1], [0, -1], [-1, 0], [1, 0], [-1,-1]]
  DELTA_KN = [[1, 2], [2, 1], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]]

  def available_moves
    [].tap do |moves_array|
      self.deltas.each do |dx, dy|
        new_pos = [self.pos.first + dx, self.pos.last + dy]
        if in_board?(new_pos)
          piece = board[new_pos]
          moves_array << new_pos if piece.nil? || enemy?(piece)
        end
      end
    end
  end
end

class King < SteppingPiece

  def deltas
    SteppingPiece::DELTA_KI
  end

  def available_moves!
    [].tap do |moves_array|
      self.deltas.each do |dx, dy|
        new_pos = [self.pos.first + dx, self.pos.last + dy]
        if in_board?(new_pos)
          piece = board[new_pos]
          moves_array << new_pos if piece.nil? || enemy?(piece)
        end
      end
    end
  end

  def available_moves
    pre_filtered_moves = super - self.board.team_moves(other_team_color)
    pre_filtered_moves.reject do |pos|
      self.board.puts_player_in_check?(self,pos)
    end
  end

  def to_s
    self.color == :black ? "\u265A".brown : "\u2654".gray
  end
end


class Knight < SteppingPiece
  def deltas
    SteppingPiece::DELTA_KN
  end

  def to_s
    self.color == :black ? "\u265E".brown : "\u2658".gray
  end
end

class Pawn < Piece
  attr_reader :first_move

  DELTA_B = [[1, 0], [2, 0]]
  DELTA_Y = [[1, 1], [1, -1]]

  def initialize(board, pos, color)
    super(board, pos, color)
    @first_move = true
  end

  def first_move?
    @first_move
  end

  def delta
    limit = self.first_move? ? 2 : 1
    if (self.color == :black)
      DELTA_B.take(limit)
    else
      DELTA_B.take(limit).map{ |x, y| [x * (-1), y * (-1)] }
    end
  end

  def pos=(position)
    @pos = position
    @first_move = false
  end

  def delta_y
    self.color == :black ? DELTA_Y : DELTA_Y.map do |x, y|
      [x * (-1), y * (-1)]
    end
  end

  def available_moves
    forward_moves + taking_moves
  end

  def forward_moves
    moves_array = []
    delta.each do |dx, dy|
      new_pos = [self.pos.first + dx, self.pos.last + dy]
      if in_board?(new_pos)
        piece = board[new_pos]
        if piece.nil?
          moves_array << new_pos
        else
          return moves_array
        end
      end
    end
    moves_array
  end

  def taking_moves
    [].tap do |moves_array|
      delta_y.each do |dx, dy|
        new_pos = [self.pos.first + dx, self.pos.last + dy]
        if in_board?(new_pos)
          piece = board[new_pos]
          moves_array << new_pos if !piece.nil? && enemy?(piece)
        end
      end
    end
  end

  def to_s
    self.color == :black ? "\u265F".brown : "\u2659".gray
  end
end