require "./language"
require "./tree"

module TreeSitter
  # A `Parser` is a stateful object that can be assigned a `Language` and used to produce a `Tree`
  # based on some source code.
  class Parser
    @parser : LibTreeSitter::TSParser

    # Used on `Parser#parse` method, the 2 parameters are
    # - byte index
    # - position
    # Return value must be a Bytes object with the data or nil if there's no more data.
    alias ReadProc = Proc(UInt32, Point, Bytes?)

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

    def parse?(old_tree : Tree?, io : IO) : Tree?
      parse?(old_tree) do |index, pos|
        slice = Bytes.new(1024)
        io.seek(index)
        n = io.read(slice)
        slice[0, n]
      end
    end

    def parse(old_tree : Tree?, io : IO) : Tree?
      parse?(old_tree, io) || raise Error.new("Parser error")
    end

    def parse?(old_tree : Tree?, string : String) : Tree?
      ptr = LibTreeSitter.ts_parser_parse_string(to_unsafe, old_tree, string, string.bytesize)

      Tree.new(ptr) if ptr
    end

    def parse(old_tree : Tree?, string : String) : Tree
      parse?(old_tree, string) || raise Error.new("Parser error")
    end

    def parse?(old_tree : Tree?, &block : ReadProc) : Tree?
      input = LibTreeSitter::TSInput.new
      input.payload = Box.box(block)
      input.encoding = LibTreeSitter::TSInputEncoding::UTF8
      input.read = ->(payload : Pointer(Void), index : UInt32, pos : LibTreeSitter::TSPoint, read : Pointer(UInt32)) do
        callback = Box(ReadProc).unbox(payload)
        bytes = callback.call(index, Point.new(pos))
        if bytes.nil?
          read.value = 0
          Pointer(LibC::Char).null
        else
          read.value = bytes.size.to_u32
          bytes.to_unsafe
        end
      end

      ptr = LibTreeSitter.ts_parser_parse(to_unsafe, old_tree, input)
      Tree.new(ptr) if ptr
    end

    def parse(old_tree : Tree?, &block : ReadProc) : Tree
      parse?(old_tree, block) || raise Error.new("Parser error")
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
