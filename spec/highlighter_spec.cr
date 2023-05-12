require "./spec_helper"

describe TreeSitter::Highlighter do
  it "can fetch all captures from a line" do
    highlighter = TreeSitter::Highlighter.new("json", %Q(\n\n[1,\n\nnull, "hey"\n]))
    highlighter.set_line_range(1, 5) # Skip first empty line

    highlighter.highlight_next_line.map(&.rule).should eq(%w())
    highlighter.highlight_next_line.map(&.rule).should eq(%w(number))
    highlighter.highlight_next_line.map(&.rule).should eq(%w())
    highlighter.highlight_next_line.map(&.rule).should eq(%w(constant.builtin string))

    highlighter.reset
    highlighter.set_line_range(4, 5)
    highlighter.highlight_next_line.map(&.rule).should eq(%w(constant.builtin string))
  end
end
