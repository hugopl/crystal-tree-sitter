require "./spec_helper"

describe TreeSitter::Parser do
  it "can parse from an IO object" do
    parser = TreeSitter::Parser.new
    parser.language = TreeSitter::Repository.load_language("json")

    io = IO::Memory.new("[1, null]")
    tree = parser.parse(nil, io).not_nil!
    tree.root_node.to_s.should eq("(document (array (number) (null)))")
  end
end
