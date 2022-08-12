require "./spec_helper"

describe TreeSitter do
  it "can reproduce the example in https://tree-sitter.github.io/tree-sitter/using-parsers" do
    parser = TreeSitter::Parser.new
    parser.language.should eq(nil)

    parser.language = TreeSitter::JSONLanguage.new
    parser.language.should_not eq(nil)

    tree = parser.parse(nil, "[1, null]")

    root_node = tree.root_node
    array_node = root_node.named_child(0)
    number_node = array_node.named_child(0)

    root_node.type.should eq("document")
    array_node.type.should eq("array")
    number_node.type.should eq("number")

    root_node.child_count.should eq(1)
    array_node.child_count.should eq(5)
    array_node.named_child_count.should eq(2)
    number_node.child_count.should eq(0)

    root_node.to_s.should eq("(document (array (number) (null)))")
  end

  it "have the available languages at compile time" do
    TreeSitter::LANGUAGE_NAMES.should eq({"JSON", "C", "Ruby"})
  end
end
