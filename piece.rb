require 'debugger'

class Piece
  attr_reader :board, :pos, :color

  def initialize(board, pos, color)
    # raise "Not enough information" if board.nil? || pos.nil?
    self.board, self.pos, self.color = board, pos, color
  end

  def available_moves
    raise NotImplementedError
  end

  def deltas
    raise NotImplementedError
  end

  def black?
    self.color == :black
  end

  def white?
    self.color == :white
  end

  def enemy?(enemy)
    self.color != enemy.color
  end

  def in_board?(pos)
    pos.first.between?(0,7) && pos.last.between?(0,7)
  end

  def to_s
    self.class.to_s[0..1]
    # self.pos.to_s
    # self.color.to_s
  end

  protected
  attr_accessor :board, :pos, :color
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
end

class Bishop < SlidingPiece
  def deltas
    SlidingPiece::DELTA_X
  end
end

class Queen < SlidingPiece
  def deltas
    SlidingPiece::DELTA_T + SlidingPiece::DELTA_X
  end
end

class SteppingPiece < Piece
  DELTA_KI = [[1, 1], [1, -1], [-1, 1], [0, 1], [0, -1], [-1, 0], [1, 0]]
  DELTA_KN = [[1, 2], [2, 1], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]]

  def available_moves
    [].tap do |moves_array|

      self.deltas.each do |dx, dy|
        new_pos = [self.pos.first + dx, self.pos.last + dy]
        piece = self.board[new_pos]

        if in_board?(new_pos) && (piece.nil? || enemy?(piece))
          moves_array << new_pos
        end
      end
    end
  end
end

class King < SteppingPiece

  def deltas
    SteppingPiece::DELTA_KI
  end
end

class Knight < SteppingPiece
  def deltas
    SteppingPiece::DELTA
  end

  # def available_moves
  #   availble_moves = super unless self.board.in_check?(self.color)
  # end
end

class Pawn < Piece
  attr_reader :first_move # come back to this for design

  def first_move?
    @first_move ||= false
  end

  def available_moves
    # [].tap do |moves_array|
    #   [0,1] || [0,-1]
    # end
  end

end