require "string_pool"
require "./point.cr"

module TreeSitter
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

    # Check if the node is *missing*. Missing nodes are inserted by the parser in
    # order to recover from certain kinds of syntax errors.
    def missing? : Bool
      LibTreeSitter.ts_node_is_missing(to_unsafe)
    end

    # Check if the node is *extra*. Extra nodes represent things like comments,
    # which are not required the grammar, but can appear anywhere.
    def extra? : Bool
      LibTreeSitter.ts_node_is_extra(to_unsafe)
    end

    # Check if a syntax node has been edited.
    def has_changes? : Bool
      LibTreeSitter.ts_node_has_changes(self)
    end

    # Check if the node is a syntax error or contains any syntax errors.
    def has_error? : Bool
      LibTreeSitter.ts_node_has_error(self)
    end

    # Get the node's immediate parent.
    def parent : Node
      Node.new(LibTreeSitter.ts_node_parent(self))
    end

    # Get the node's child at the given index, where zero represents the first
    # child.
    #
    # Raises `IndexError` if index is out of bounds.
    def child(index : Int32) : Node
      raise IndexError.new if index < 0 || index >= child_count

      Node.new(LibTreeSitter.ts_node_child(self, index.to_u32))
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

    def descendant(start_byte : UInt32, end_byte : UInt32) : Node?
      ptr = LibTreeSitter.ts_node_descendant_for_byte_range(to_unsafe, start_byte, end_byte)
      Node.new(ptr)
    end

    def descendant(start_point : Point, end_point : Point) : Node?
      ptr = LibTreeSitter.ts_node_descendant_for_point_range(to_unsafe, start_point, end_point)
      Node.new(ptr)
    end

    def ==(other : Node) : Bool
      LibTreeSitter.ts_node_eq(self, other)
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
