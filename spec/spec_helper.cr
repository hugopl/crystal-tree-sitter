require "spec"
require "../src/tree_sitter"

def parse_json(code : String) : TreeSitter::Tree
  parser = TreeSitter::Parser.new("json")
  parser.parse(nil, code).not_nil!
end
