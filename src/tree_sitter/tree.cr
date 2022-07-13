require "./node"

module TreeSitter
  # A `Tree` represents the syntax tree of an entire source code file. It contains `Node` instances
  # that indicate the structure of the source code. It can also be edited and used to produce a new
  # `Tree` in the event that the source code changes.
  class Tree
    @tree : LibTreeSitter::TSTree

    # :nodoc:
    protected def initialize(@tree)
    end

    # :nodoc:
    def finalize
      LibTreeSitter.ts_tree_delete(to_unsafe)
    end

    # Create a shallow copy of the syntax tree. This is very fast.
    #
    # You need to copy a syntax tree in order to use it on more than one thread at
    # a time, as syntax trees are not thread safe.
    def copy : Tree
      Tree.new(LibTreeSitter.ts_tree_copy(to_unsafe))
    end

    # Get the root node of the syntax tree.
    def root_node : Node
      Node.new(LibTreeSitter.ts_tree_root_node(to_unsafe))
    end

    # :nodoc:
    def to_unsafe
      @tree
    end
  end
end
