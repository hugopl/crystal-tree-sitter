require "./lib_tree_sitter"
require "./tree_sitter/parser"
require "./tree_sitter/highlighter"
require "./tree_sitter/query"
require "./tree_sitter/query_cursor"

{% if flag?(:doc) %}
  # A tuple with all supported languages.
  LANGUAGE_NAMES = {"Language 1", "Language 2", "..."}
{% end %}

private def calloc(n : LibC::SizeT, size : LibC::SizeT) : Pointer(Void)
  GC.malloc(n * size)
end

# Generate bindings for a language parser
#
# If you do:
#
# ```Crystal
# require_tree_sitter_languages("json", "../some-dir")
# ```
#
# *languages* is a list of language parsers names or language parsers directories.
#
# The C compiler used to generate the library is what's in *CC* environment variable or `cc`.
@[Experimental]
macro require_tree_sitter_languages(*languages)
  {{ run "./bind_gen", languages.map(&.id).join(" ") }}
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

  # Init tree-sitter by telling it to use the Crystal GC as memory allocator.
  # This is called automatically when you require tree-sitter unless you compile with `-Dno_init_tree_sitter`.
  def init
    LibTreeSitter.ts_set_allocator(->GC.malloc, ->calloc, ->GC.realloc, ->GC.free)
  end

  extend self
end

{% unless flag?(:crystal_tree_sitter_no_init) %}
  TreeSitter.init
{% end %}
