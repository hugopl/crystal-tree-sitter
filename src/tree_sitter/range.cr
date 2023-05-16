module TreeSitter
  # A range defined in terms of points and byte offsets.
  struct Range
    struct Iterator
      include ::Iterator(Range)

      @ranges : Pointer(LibTreeSitter::TSRange)
      @length : UInt32

      protected def initialize(@ranges, @length)
      end

      def next
        return stop if @length.zero?

        Range.new(@ranges.value).tap do
          @length -= 1
          @ranges += 1
        end
      end
    end

    @range : LibTreeSitter::TSRange

    protected def initialize(@range)
    end

    def initialize
      @range = LibTreeSitter::TSRange.new
    end

    def initialize(start_byte : UInt32, end_byte : UInt32,
                   start_row : Int32, start_column : Int32,
                   end_row : Int32, end_column : Int32)
      start_point = LibTreeSitter::TSPoint.new(row: start_row, column: start_column)
      end_point = LibTreeSitter::TSPoint.new(row: end_row, column: end_column)
      @range = LibTreeSitter::TSRange.new(start_byte: start_byte, end_byte: end_byte,
        start_point: start_point, end_point: end_point)
    end

    def initialize(start_byte : UInt32, end_byte : UInt32, start_point : Point, end_point : Point)
      @range = LibTreeSitter::TSRange.new(start_byte: start_byte, end_byte: end_byte,
        start_point: start_point, end_point: end_point)
    end

    def start_point : Point
      Point.new(@range.start_point)
    end

    def start_point=(point : Point) : Point
      @range.start_point = point.to_unsafe
      point
    end

    def end_point : Point
      Point.new(@range.end_point)
    end

    def end_point=(point : Point) : Point
      @range.end_point = point.to_unsafe
      point
    end

    delegate start_byte, to: @range
    delegate :start_byte=, to: @range
    delegate end_byte, to: @range
    delegate :end_byte=, to: @range

    def to_unsafe
      @range
    end
  end
end
