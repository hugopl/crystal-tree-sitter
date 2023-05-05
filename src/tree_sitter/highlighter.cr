require "./query_cursor"

module TreeSitter
  class Highlighter
    include Iterator(Capture)

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
      capture = @cursor.next_capture
      capture ? capture : stop
    end

    # FIXME: This isn´t ready, it's just enough for me to test other things.
    def each_rule_for_line(line : Int32)
      last_capture = @cursor.last_capture
      yield(last_capture) if last_capture && last_capture.includes_line?(line)

      each do |capture|
        next if capture < line
        break unless capture.includes_line?(line)

        yield(capture)
      end
    end
  end
end
