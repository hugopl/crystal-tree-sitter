module TreeSitter
  class Highlighter
    include Iterator(Tuple(String, Node))

    @cursor : TreeSitter::QueryCursor

    def initialize(lang : Language, node : Node)
      @cursor = TreeSitter::QueryCursor.new
      query = lang.highlight_query
      @cursor.exec(query, node)
    end

    def next
      item = @cursor.next_capture
      item ? item : stop
    end
  end
end
