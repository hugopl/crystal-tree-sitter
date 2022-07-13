module TreeSitter
  class Highlighter
    @lang : Language

    def initialize(@lang : Language)
    end

    def highlight(node : Node)
      cursor = TreeSitter::QueryCursor.new
      query = @lang.highlight_query
      cursor.exec(query, node) do |rule, node|
        yield(rule, node)
      end
    end
  end
end
