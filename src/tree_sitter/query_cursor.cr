module TreeSitter
  class QueryCursor
    @cursor : LibTreeSitter::TSQueryCursor
    @query : Query?

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

    def exec(query : Query, node : Node)
      @query = query
      LibTreeSitter.ts_query_cursor_exec(to_unsafe, query, node)
    end

    def next_capture : {String, Node}?
      query = @query
      return if query.nil?

      ok = LibTreeSitter.ts_query_cursor_next_capture(to_unsafe, out match, out capture_index)
      return unless ok

      capture = match.captures[capture_index]
      ptr = LibTreeSitter.ts_query_capture_name_for_id(query, capture.index, out strlen)
      rule = TreeSitter.string_pool.get(ptr, strlen)
      node = Node.new(capture.node)

      {rule, node}
    end

    # Start running a given query on a given node.
    #
    # Yield the capture name and the node
    def exec(query : Query, node : Node, &block)
      exec(query, node)

      loop do
        rule_node = next_capture
        break if rule_node.nil?

        yield(*rule_node)
      end
    end

    def to_unsafe
      @cursor
    end
  end
end
