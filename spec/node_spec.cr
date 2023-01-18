require "./spec_helper"

describe TreeSitter::Node do
  it "can get node start/end points" do
    root_node = parse_json("[1,\n null]").root_node
    array_node = root_node.named_child(0)
    null_node = array_node.named_child(1)
    null_node.start_point.should eq({1, 1})
    null_node.end_point.should eq({1, 5})
  end

  it "can get node start/end byte" do
    root_node = parse_json("[1,\n null]").root_node
    array_node = root_node.named_child(0)
    null_node = array_node.named_child(1)
    null_node.start_byte.should eq(5)
    null_node.end_byte.should eq(9)
  end

  it "#descendant_for_byte_range" do
    root_node = parse_json("[1, null]").root_node
    root_node.descendant(6, 7).to_s.should eq("(null)")
  end

  it "#descendant_for_byte_range" do
    root_node = parse_json("[1,\nnull]").root_node
    root_node.descendant(TreeSitter::Point.new(1, 0), TreeSitter::Point.new(1, 2)).to_s.should eq("(null)")
  end
end
