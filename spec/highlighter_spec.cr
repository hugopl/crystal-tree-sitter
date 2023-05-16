require "./spec_helper"

describe TreeSitter::Highlighter do
  it "can fetch all captures from a line" do
    parser = TreeSitter::Parser.new("json")
    tree = parser.parse(nil, %Q(\n\n[1,\n\nnull, "hey"\n]))

    highlighter = TreeSitter::Highlighter.new(parser.language)
    highlighter.set_line_range(1, 5) # Skip first empty line
    highlighter.exec(tree.root_node)

    highlighter.highlight_next_line.map(&.rule).should eq(%w())
    highlighter.highlight_next_line.map(&.rule).should eq(%w(number))
    highlighter.highlight_next_line.map(&.rule).should eq(%w())
    highlighter.highlight_next_line.map(&.rule).should eq(%w(constant.builtin string))

    highlighter.exec(tree.root_node)
    highlighter.set_line_range(4, 5)
    highlighter.highlight_next_line.map(&.rule).should eq(%w(constant.builtin string))
  end
end
