module TreeSitter
  record Capture, rule : String, node : Node do
    def includes_line?(line_n : Int32) : Bool
      node.start_point.row == line_n || node.end_point.row == line_n
    end

    def <(line : Int32) : Bool
      node.end_point.row < line && node.start_point.row < line
    end

    def to_s(io : IO)
      io << @rule << ' '
      node.to_s(io)
    end

    def inspect(io : IO)
      io << "#<Capture "
      to_s(io)
      io << " start="
      node.start_point.to_s(io)
      io << " end="
      node.end_point.to_s(io)
      io << '>'
    end
  end
end
