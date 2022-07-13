require "./spec_helper"

describe TreeSitter::Language do
  it "have flags from package.json at compile time" do
    lang = TreeSitter::JSONLanguage.new
    lang.version.to_s.should eq("0.20.0")
    lang.file_types.should eq(%w(json))
    lang.highlight_query.should_not eq(nil)
  end

  it "share the same instance" do
    lang1 = TreeSitter::JSONLanguage.new
    lang2 = TreeSitter::JSONLanguage.new
    lang1.object_id.should eq(lang2.object_id)
  end
end
