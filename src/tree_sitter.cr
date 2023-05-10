require "./lib_tree_sitter"
require "./tree_sitter/parser"
require "./tree_sitter/repository"
require "./tree_sitter/highlighter"
require "./tree_sitter/query"
require "./tree_sitter/query_cursor"
require "./tree_sitter/editor"

private def calloc(n : LibC::SizeT, size : LibC::SizeT) : Pointer(Void)
  GC.malloc(n * size)
end

module TreeSitter
  VERSION = "0.1.0"

  # Base class for all TreeSitter errors.
  class Error < RuntimeError
  end

  enum SymbolType
    Regular
    Anonymous
    Auxiliary
  end

  protected class_getter string_pool = StringPool.new

  # Init tree-sitter by telling it to use the Crystal GC as memory allocator.
  # This is called automatically when you require tree-sitter unless you compile with `-Dcrystal_tree_sitter_no_init`.
  def init
    LibTreeSitter.ts_set_allocator(->GC.malloc, ->calloc, ->GC.realloc, ->GC.free)
  end

  extend self
end

{% unless flag?(:crystal_tree_sitter_no_init) %}
  TreeSitter.init
{% end %}
