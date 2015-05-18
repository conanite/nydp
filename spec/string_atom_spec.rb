require "spec_helper"

describe Nydp::StringAtom do
  it "returns its string in #to_ruby" do
    s = Nydp::StringAtom.new "harrypotter"
    expect(s.to_ruby).to eq "harrypotter"
    expect(s.to_ruby.class).to eq String
  end
end
