require "./spec_helper"

describe TreeSitter::Language do
  it "have flags from package.json at compile time" do
    lang = TreeSitter::JSONLanguage.new
    lang.version.to_s.should eq("0.20.0")
    lang.highlight_query.should_not eq(nil)
  end

  it "share the same instance" do
    lang1 = TreeSitter::JSONLanguage.new
    lang2 = TreeSitter::JSONLanguage.new
    lang1.object_id.should eq(lang2.object_id)
  end

  it "can detect language from file path" do
    TreeSitter::Language.detect("foo.json").should be_a(TreeSitter::JSONLanguage)
    TreeSitter::Language.detect("foo.c").should be_a(TreeSitter::CLanguage)
    TreeSitter::Language.detect("foo.h").should be_a(TreeSitter::CLanguage)
    TreeSitter::Language.detect("foo.abc").should eq(nil)
  end
end
