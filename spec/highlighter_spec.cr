require "./spec_helper"

describe TreeSitter::Highlighter do
  it "can highlight json code" do
    highlighter = TreeSitter::Highlighter.new("json", "[1, null]")
    rules = [] of String
    nodes = [] of String
    highlighter.each do |rule, node|
      rules << rule
      nodes << node.to_s
    end
    nodes.should eq(["(number)", "(null)"])
    rules.should eq(%w(number constant.builtin))
  end

  it "can highlight C code" do
    highlighter = TreeSitter::Highlighter.new("c", "void main() {}")
    rules = [] of String
    nodes = [] of String
    highlighter.each do |rule, node|
      rules << rule
      nodes << node.to_s
    end
    nodes.should eq(["(primitive_type)", "(identifier)", "(identifier)", "(identifier)"])
    rules.should eq(%w(type function constant variable))
  end
end
