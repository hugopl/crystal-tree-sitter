require "string_pool"

module TreeSitter
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

  # A `Node` represents a single node in the syntax tree. It tracks its start and end positions in
  # the source code, as well as its relation to other nodes like its parent, siblings and children.
  struct Node
    @node : LibTreeSitter::TSNode
    @@string_pool = StringPool.new

    # :nodoc:
    def initialize(@node)
    end

    # Get the node's number of children
    def child_count : UInt32
      LibTreeSitter.ts_node_child_count(to_unsafe)
    end

    # Get the node's number of *named* children.
    #
    # See also `#named?`
    def named_child_count : UInt32
      LibTreeSitter.ts_node_named_child_count(to_unsafe)
    end

    # Get the node's *named* child at the given index.
    #
    # See also `#named?`
    def named_child(index : Int32)
      Node.new(LibTreeSitter.ts_node_named_child(to_unsafe, index))
    end

    # Check if the node is *named*. Named nodes correspond to named rules in the
    # grammar, whereas *anonymous* nodes correspond to string literals in the
    # grammar.
    def named? : Bool
      LibTreeSitter.ts_node_is_named(to_unsafe)
    end

    # Get the node's type as a String.
    def type : String
      cstr = LibTreeSitter.ts_node_type(to_unsafe)
      @@string_pool.get(cstr, LibC.strlen(cstr))
    end

    # Get the node's start byte.
    def start_byte : UInt32
      LibTreeSitter.ts_node_start_byte(to_unsafe)
    end

    # Get the node's end byte.
    def end_byte : UInt32
      LibTreeSitter.ts_node_end_byte(to_unsafe)
    end

    # Get the node's start position in terms of rows and columns.
    def start_point : Point
      Point.new(LibTreeSitter.ts_node_start_point(to_unsafe))
    end

    # Get the node's end position in terms of rows and columns.
    def end_point : Point
      Point.new(LibTreeSitter.ts_node_end_point(to_unsafe))
    end

    # Get an S-expression representing the node as a string.
    def to_s(io : IO)
      ptr = LibTreeSitter.ts_node_string(to_unsafe)
      bytes = Bytes.new(ptr, LibC.strlen(ptr))
      io.write(bytes)
    end

    # :nodoc:
    def to_unsafe
      @node
    end
  end
end
