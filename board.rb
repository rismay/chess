class Board
  attr_reader :grid

  def grid
    @grid ||= [[nil] * 8] * 8
  end

  def checkmate?
    # if either kings have no moves, checkmate.
    false
  end
end