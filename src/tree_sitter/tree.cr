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

    def changed_ranges(old_tree : Tree) : Range::Iterator
      ranges = LibTreeSitter.ts_tree_get_changed_ranges(old_tree, self, out length)
      Range::Iterator.new(ranges, length)
    end

    # Write a DOT graph describing the syntax tree to the given file.
    def save_dot(io : IO::FileDescriptor)
      LibTreeSitter.ts_tree_print_dot_graph(to_unsafe, io.fd)
    end

    # Write a DOT graph describing the syntax tree to the given file.
    def save_dot(file : Path | String)
      File.open(file, "w") do |file|
        save_dot(file)
      end
    end

    # Write a PNG graph describing the syntax tree to the given file.
    def save_png(file : Path | String) : Nil
      tempfile = File.tempfile("tree")
      save_dot(tempfile)
      tempfile.close
      `dot -Tpng #{tempfile.path} > #{file}`
    ensure
      tempfile.try(&.delete)
    end

    # :nodoc:
    def to_unsafe
      @tree
    end
  end
end
