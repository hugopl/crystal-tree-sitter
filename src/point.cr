module TreeSitter
  struct Point
    @data = LibTreeSitter::TSPoint

    def initialize(@data)
    end

    def initialize
      @data = LibTreeSitter::TSPoint.new
    end

    delegate row, to: @data
    delegate :row=, to: @data
    delegate column, to: @data
    delegate :column=, to: @data

    def to_unsafe
      @data
    end
  end
end
