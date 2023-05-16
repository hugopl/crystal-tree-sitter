require "./spec_helper"

describe TreeSitter::Range do
  it "can be constructed with points" do
    range = TreeSitter::Range.new(1_u32, 2_u32, TreeSitter::Point.new(1, 2), TreeSitter::Point.new(3, 4))
    range.start_byte.should eq(1)
    range.end_byte.should eq(2)
    range.start_point.should eq(TreeSitter::Point.new(1, 2))
    range.end_point.should eq(TreeSitter::Point.new(3, 4))
  end

  it "can be constructed with integer arguments" do
    range = TreeSitter::Range.new(1_u32, 2_u32, 1, 2, 3, 4)
    range.start_byte.should eq(1)
    range.end_byte.should eq(2)
    range.start_point.should eq(TreeSitter::Point.new(1, 2))
    range.end_point.should eq(TreeSitter::Point.new(3, 4))
  end

  it "have setters for start/end points" do
    range = TreeSitter::Range.new
    range.start_point = TreeSitter::Point.new(1, 2)
    range.start_point.should eq(TreeSitter::Point.new(1, 2))
    range.end_point = TreeSitter::Point.new(3, 4)
    range.end_point.should eq(TreeSitter::Point.new(3, 4))
  end
end
