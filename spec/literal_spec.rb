require 'spec_helper'

describe Nydp::Literal do
  it "returns a ruby symbol in #to_ruby" do
    sym = Nydp::Symbol.mk :foo, ns
    lit = Nydp::Literal.new sym
    expect(lit.to_ruby).to eq :foo
  end

  describe "t" do
    it "is #true in ruby" do
      expect(Nydp.T.to_ruby).to eq true
    end
  end

  describe "nil" do
    it "is #nil in ruby" do
      expect(Nydp.NIL.to_ruby).to eq nil
    end
  end
end
