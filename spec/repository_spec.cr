require "./spec_helper"

describe TreeSitter::Repository do
  # parsers for json and C must be installed at least
  it "can fetch installed languages" do
    TreeSitter::Repository.language_names.should_not eq(%w())
  end
end
