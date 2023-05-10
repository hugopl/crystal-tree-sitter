require "spec"
require "../src/tree_sitter"

def point_to_offset(line : Int32, col : Int32) : UInt32
  col.to_u32
end

def offset_to_point(offset : UInt32) : TreeSitter::Point
  TreeSitter::Point.new(0, offset)
end

def parse_json(code : String) : TreeSitter::Tree
  parser = TreeSitter::Parser.new("json")
  parser.parse(nil, code).not_nil!
end
