require "./spec_helper"

describe TreeSitter::Highlighter do
  it "can highlight code" do
    language = TreeSitter::JSONLanguage.new
    parser = TreeSitter::Parser.new(language: language)
    tree = parser.parse(nil, "[1, null]")
    root_node = tree.root_node

    highlighter = TreeSitter::Highlighter.new(language, root_node)
    rules = [] of String
    nodes = [] of String
    highlighter.each do |rule, node|
      rules << rule
      nodes << node.to_s
    end
    nodes.should eq(["(number)", "(null)"])
    rules.should eq(%w(number constant.builtin))
  end
end
