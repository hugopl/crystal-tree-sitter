require "spec"
require "../src/tree_sitter"

require_tree_sitter_languages("json:JSON", "c", "ruby")

def parse_json(code : String) : TreeSitter::Tree
  parser = TreeSitter::Parser.new(language: TreeSitter::JSONLanguage.new)
  parser.parse(nil, code).not_nil!
end
