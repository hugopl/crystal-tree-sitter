require "./query_cursor"

module TreeSitter
  class Highlighter < QueryCursor
    @pending_capture : Capture?
    @current_line : Int32 = 0

    def initialize(query : Query)
      super
    end

    def initialize(language : Language)
      query = language.highlight_query
      super(query)
    end

    def set_line_range(start_line : Int32, end_line : Int32)
      set_point_range(start_line, 0, end_line, 0)
      @current_line = start_line
    end

    def highlight_next_line : Array(Capture)
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
        capture = next_capture
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
