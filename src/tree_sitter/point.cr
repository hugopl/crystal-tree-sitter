module TreeSitter
  # A point is a line/column tuple.
  struct Point
    @point : LibTreeSitter::TSPoint

    def initialize(@point)
    end

    def initialize(row : UInt32, column : UInt32)
      @point = LibTreeSitter::TSPoint.new(row: row, column: column)
    end

    delegate row, to: @point
    delegate :row=, to: @point
    delegate column, to: @point
    delegate :column=, to: @point

    def ==(tuple : Tuple(Int32, Int32))
      @point.row == tuple[0] && @point.column == tuple[1]
    end

    # Returns the point as a tuple of {row, column}.
    def to_tuple : Tuple(Int32, Int32)
      {row, column}
    end

    def inspect(io : IO)
      io << '{' << row << ", " << column << '}'
    end

    def to_unsafe
      @point
    end
  end
end
