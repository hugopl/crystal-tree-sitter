require "./spec_helper"

describe TreeSitter::Tree do
  it "can generate dot graphs" do
    parser = TreeSitter::Parser.new("json")

    tree = parser.parse(nil, "[1, null]").not_nil!
    tree.save_dot("tree.dot")
    File.exists?("tree.dot").should eq(true)
    File.read("tree.dot").should start_with("digraph tree {")
    File.delete("tree.dot")
  end

  it "can generate dot graphs PNGs (if graphviz is installed)" do
    parser = TreeSitter::Parser.new("json")

    tree = parser.parse(nil, "[1, null]").not_nil!
    tree.save_png("tree.png")
    File.exists?("tree.png").should eq(true)
    File.delete("tree.png")
  end
end
