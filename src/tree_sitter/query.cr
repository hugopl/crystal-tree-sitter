module TreeSitter
  # A query consists of one or more patterns, where each pattern is an S-expression
  # that matches a certain set of nodes in a syntax tree. The expression to match a
  # given node consists of a pair of parentheses containing two things: the node’s type,
  # and optionally, a series of other S-expressions that match the node’s children.
  class Query
    @query : LibTreeSitter::TSQuery

    # Create a new query from a string containing one or more S-expression
    # patterns. The query is associated with a particular language, and can
    # only be run on syntax nodes parsed with that language.
    #
    # If all of the given patterns are valid, this returns a `Query`.
    # If a pattern is invalid, this raises an `Error` exception that provides two pieces
    # of information about the problem:
    # 1. The byte offset of the error.
    # 2. The type of error.
    def initialize(language : Language, source : String)
      query = LibTreeSitter.ts_query_new(language, source, source.bytesize, out error_offset, out error_type)
      if error_type.none?
        @query = query
      else
        # FIXME: This is horrible, transform this into a set of exceptions with a nice error message.
        raise Error.new("#{error_type} at #{error_offset}")
      end
    end

    # :nodoc:
    def finalize
      LibTreeSitter.ts_query_delete(to_unsafe)
    end

    def pattern_count : UInt32
      LibTreeSitter.ts_query_pattern_count(to_unsafe)
    end

    def capture_count : UInt32
      LibTreeSitter.ts_query_capture_count(to_unsafe)
    end

    def string_count : UInt32
      LibTreeSitter.ts_query_string_count(to_unsafe)
    end

    # :nodoc:
    def to_unsafe
      @query
    end
  end
end
