require "./language"
require "./tree"

module TreeSitter
  # A `Parser` is a stateful object that can be assigned a `Language` and used to produce a `Tree`
  # based on some source code.
  class Parser
    @parser : LibTreeSitter::TSParser

    # Create a new parser.
    def initialize(*, language : Language? = nil)
      @parser = LibTreeSitter.ts_parser_new
      self.language = language if language
    end

    # :nodoc:
    def finalize
      LibTreeSitter.ts_parser_delete(to_unsafe)
    end

    # Set the language that the parser should use for parsing.
    #
    # Raises `Error` if the language version is incompatible with treesitter library.
    def language=(language : Language) : Language
      ok = LibTreeSitter.ts_parser_set_language(to_unsafe, language)
      raise Error.new("Incompatible language") unless ok

      language
    end

    # Get the parser's current language.
    def language : Language?
      ptr = LibTreeSitter.ts_parser_language(to_unsafe)
      Language.new(ptr) if ptr
    end

    def parse_string(old_tree : Tree?, string : String) : Tree?
      ptr = LibTreeSitter.ts_parser_parse_string(to_unsafe, old_tree, string, string.bytesize)
      raise Error.new("Parser error") if ptr.null?

      Tree.new(ptr)
    end

    # Instruct the parser to start the next parse from the beginning.
    #
    # If the parser previously failed because of a timeout or a cancellation, then
    # by default, it will resume where it left off on the next call to
    # `#parse` or other parsing methods. If you don't want to resume,
    # and instead intend to use this parser to parse some other document, you must
    # call `#reset` first.
    def reset
      LibTreeSitter.ts_parser_reset(to_unsafe)
    end

    # Set the file descriptor to which the parser should write debugging graphs
    # during parsing. The graphs are formatted in the DOT language. You may want
    # to pipe these graphs directly to a `dot(1)` process in order to generate
    # SVG output. You can turn off this logging by passing nil.
    def print_dot_graphs(io : IO::FileDescriptor?) : Nil
      fd = io.nil? ? -1 : io.fd
      LibTreeSitter.ts_parser_print_dot_graphs(to_unsafe, fd)
    end

    # :nodoc:
    def to_unsafe
      @parser
    end
  end
end
