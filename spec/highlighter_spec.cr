require "./spec_helper"

describe TreeSitter::Highlighter do
  it "can highlight json code" do
    highlighter = TreeSitter::Highlighter.new("json", "[1, null]")
    captures = [] of TreeSitter::Capture
    highlighter.each do |capture|
      captures << capture
    end
    captures.map(&.to_s).should eq(["number (number)", "constant.builtin (null)"])
  end

  it "can highlight C code" do
    highlighter = TreeSitter::Highlighter.new("c", "void main() {}")
    captures = [] of TreeSitter::Capture
    highlighter.each do |capture|
      captures << capture
    end
    captures.map(&.to_s).should eq(["type (primitive_type)",
                                    "function (identifier)",
                                    "constant (identifier)",
                                    "variable (identifier)"])
  end

  it "can tell rules by line numbers" do
    highlighter = TreeSitter::Highlighter.new("json", "[1,\nnull]")
    captures = [] of TreeSitter::Capture
    highlighter.each_rule_for_line(0) do |capture|
      captures << capture
    end
    captures.map(&.to_s).should eq(["number (number)"])

    captures.clear
    highlighter.each_rule_for_line(1) do |capture|
      captures << capture
    end
    captures.map(&.to_s).should eq(["constant.builtin (null)"])
  end
end
