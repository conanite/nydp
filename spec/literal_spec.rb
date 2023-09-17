require 'spec_helper'

describe Nydp::Literal do
  it "returns a ruby symbol in #to_ruby" do
    sym = :foo
    lit = Nydp::Literal.new sym
    expect(lit.to_ruby).to eq :foo
  end

  describe "t" do
    it "is #true in ruby" do
      expect(true.to_ruby).to eq true
    end
  end

  describe "nil" do
    it "is #nil in ruby" do
      expect(nil.to_ruby).to eq nil
    end
  end

  describe "false" do
    it "is stored in toplevel namespace" do
      false_ns = Nydp::Namespace.new
      Nydp::Core.new.setup false_ns
      expect(false_ns.ns_false).to eq false
    end
  end
end
