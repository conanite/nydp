require "spec_helper"

describe Nydp::StringFragmentToken do
  it "is equal to another token with the same content" do
    t1 = Nydp::StringFragmentToken.new "foo", "bar"
    t2 = Nydp::StringFragmentToken.new "foo", "zub"
    expect(t1).to eq t2
  end

  it "is not equal to another string with the same content" do
    t1 = Nydp::StringFragmentToken.new "foo", "bar"
    expect(t1).not_to eq "foo"
  end

  it "is not equal to nil" do
    t1 = Nydp::StringFragmentToken.new "foo", "bar"
    expect(t1).not_to eq Nydp.NIL
  end
end
