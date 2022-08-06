module TreeSitter
  struct Point
    @data = LibTreeSitter::TSPoint

    def initialize(@data)
    end

    def to_unsafe
      @data
    end
  end
end
