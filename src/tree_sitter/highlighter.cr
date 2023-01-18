module TreeSitter
  class Highlighter
    include Iterator(Tuple(String, Node))

    @cursor = TreeSitter::QueryCursor.new

    def initialize(language : Language, node : Node)
      query = language.highlight_query
      @cursor.exec(query, node)
    end

    def initialize(language_name : String, code : String)
      parser = TreeSitter::Parser.new(language_name)
      tree = parser.parse(nil, code)
      initialize(parser.language, tree.root_node)
    end

    def next
      item = @cursor.next_capture
      item ? item : stop
    end
  end
end
