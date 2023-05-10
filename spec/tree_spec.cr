require "./spec_helper"

private def point_to_offset(line : Int32, col : Int32) : UInt32
  col.to_u32
end

private def offset_to_point(offset : UInt32) : TreeSitter::Point
  TreeSitter::Point.new(0, offset)
end

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

  it "can be editted" do
    parser = TreeSitter::Parser.new("json")
    tree = parser.parse(nil, "[1, null]").not_nil!
    editor = TreeSitter::TreeEditor.new(tree, ->point_to_offset(Int32, Int32), ->offset_to_point(UInt32))
    editor.delete(line: 0, column: 1, n_bytes: 1)
    editor.insert(line: 0, column: 1, n_bytes: 2)
    new_tree = parser.parse(editor.tree, "[null, null]")
    new_tree.root_node.to_s.should eq("(document (array (null) (null)))")
  end
end
