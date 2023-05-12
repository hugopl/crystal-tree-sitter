require "./query_cursor"

module TreeSitter
  class Highlighter
    @cursor : TreeSitter::QueryCursor
    @node : Node
    @pending_capture : Capture?
    @current_line : Int32 = 0
    @started : Bool = false

    def initialize(language : Language, @node : Node)
      query = language.highlight_query
      @cursor = TreeSitter::QueryCursor.new(query)
    end

    def initialize(language_name : String, code : String)
      parser = TreeSitter::Parser.new(language_name)
      tree = parser.parse(nil, code)
      initialize(parser.language, tree.root_node)
    end

    def set_line_range(start_line : Int32, end_line : Int32)
      @cursor.set_point_range(Point.new(start_line, 0_u32), Point.new(end_line, 0_u32))
      @current_line = start_line
    end

    def reset
      @started = false
      @current_line = 0
    end

    private def exec : Nil
      @cursor.exec(@node)
      @started = true
    end

    def highlight_next_line : Array(Capture)
      exec unless @started

      captures = [] of Capture
      expected_line = @current_line
      pending_capture = @pending_capture

      if pending_capture
        if !pending_capture.includes_line?(expected_line)
          return captures
        end

        captures << pending_capture
        @pending_capture = nil
      end

      loop do
        capture = @cursor.next_capture
        break if capture.nil?

        capture_line = capture.node.end_point.row
        if capture.includes_line?(expected_line)
          captures << capture
        else
          @pending_capture = capture
          break
        end
      end
      captures
    ensure
      @current_line += 1
    end

    private def valid_capture?(capture : Capture) : Bool
      capture.start_point.row == expected_line || capture.start_point.row end_pos
    end
  end
end
