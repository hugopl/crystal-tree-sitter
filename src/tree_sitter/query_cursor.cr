module TreeSitter
  class QueryCursor
    @cursor : LibTreeSitter::TSQueryCursor

    # Create a new cursor for executing a given query.
    #
    # The cursor stores the state that is needed to iteratively search
    # for matches. To use the query cursor, call `QueryCursor#exec`
    # to start running a given query on a given syntax node.
    def initialize
      @cursor = LibTreeSitter.ts_query_cursor_new
    end

    def finalize
      LibTreeSitter.ts_query_cursor_delete(to_unsafe)
    end

    # Start running a given query on a given node.
    #
    # Yield the capture name and the node
    def exec(query : Query, node : Node, &block)
      LibTreeSitter.ts_query_cursor_exec(to_unsafe, query, node)

      loop do
        ok = LibTreeSitter.ts_query_cursor_next_capture(to_unsafe, out match, out capture_index)
        return unless ok

        capture = match.captures[capture_index]
        ptr = LibTreeSitter.ts_query_capture_name_for_id(query, capture.index, out strlen)
        rule = String.new(ptr, strlen, strlen)
        node = Node.new(capture.node)
        yield(rule, node)
      end
    end

    def to_unsafe
      @cursor
    end
  end
end
