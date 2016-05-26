require "spec_helper"

describe Nydp::Pair do
  let(:a)                { Nydp::Symbol.mk :a,                  ns }
  let(:b)                { Nydp::Symbol.mk :b,                  ns }
  let(:c)                { Nydp::Symbol.mk :c,                  ns }
  let(:d)                { Nydp::Symbol.mk :d,                  ns }
  let(:foo)              { Nydp::Symbol.mk :foo,                ns }
  let(:dot)              { Nydp::Symbol.mk ".".to_sym,          ns }

  describe "#map" do
    it "behaves like ruby #map" do
      list = pair_list [1,2,3]
      mapped = list.map { |x| x * 2 }
      expect(mapped).to eq [2,4,6]
    end
  end

  describe :== do
    it "should be true for two empty lists" do
      expect(Nydp::Pair.new(NIL, NIL)).to eq Nydp::Pair.new(NIL, NIL)
    end

    it "should be true for nested empty lists" do
      e1 = Nydp::Pair.new(Nydp::NIL, Nydp::NIL)
      e2 = Nydp::Pair.new(Nydp::NIL, Nydp::NIL)
      e3 = Nydp::Pair.new(Nydp::NIL, Nydp::NIL)
      e4 = Nydp::Pair.new(Nydp::NIL, Nydp::NIL)
      expect(Nydp::Pair.new(e1, e2)).to eq Nydp::Pair.new(e3, e4)
    end

    it "should define #== to return true for an identical list" do
      p1 = pair_list [:a, :b, :c, :d]
      p2 = pair_list [:a, :b, :c, :d]
      expect(p1).to eq p2
    end

    it "should define #== to return true for identical improper lists" do
      p1 = pair_list [:a, :b, :c, :d], 4
      p2 = pair_list [:a, :b, :c, :d], 4
      expect(p1).to eq p2
    end

    it "should define #== to return false for a non-identical list" do
      p1 = pair_list [:a, :b, :c, :d]
      p2 = pair_list [:a, :b, :c, 22]
      expect(p1).not_to eq p2
    end

    it "should define #== to return false for lists which differ only in their terminating element" do
      p1 = pair_list [:a, :b, :c], :d
      p2 = pair_list [:a, :b, :c], 22
      expect(p1).not_to eq p2
    end
  end

  it "should create a new pair" do
    p = Nydp::Pair.new :a, :b
    expect(p.car).to eq :a
    expect(p.cdr).to eq :b
  end

  it "should convert from a ruby list" do
    p = pair_list [:a, :b, :c, :d]
    expect(p.car).to eq :a
    p = p.cdr
    expect(p.car).to eq :b
    p = p.cdr
    expect(p.car).to eq :c
    p = p.cdr
    expect(p.car).to eq :d
    p = p.cdr
    expect(p.car).to eq Nydp::NIL
    expect(p.cdr).to eq Nydp::NIL
    p = p.cdr
    expect(p.car).to eq Nydp::NIL
    expect(p.cdr).to eq Nydp::NIL
  end

  it "should convert to a ruby list" do
    pair = pair_list [:a, :b, :c, :d]
    ruby = pair.to_ruby
    expect(ruby).to eq [:a, :b, :c, :d]
  end

  it "should have size zero when empty" do
    expect(pair_list([]).size).to eq 0
  end

  it "should report the number of elements is contains" do
    expect(pair_list([:a, :b, :c]).size).to eq 3
  end

  it "should report the number of elements in an improper list, excluding last item" do
    expect(pair_list([:a, :b, :c, :d], :foo).size).to eq 4
  end

  it "should represent itself as a string" do
    expect(pair_list([a, b, c, d]).to_s).to eq "(a b c d)"
  end

  it "should represent an improper list as a string" do
    expect(pair_list([a, b, c, d], foo).to_s).to eq "(a b c d . foo)"
  end

  it "should parse a list" do
    p = pair_list [a, b, c, d]
    expect(Nydp::Pair.parse_list([a, b, c, d])).to eq p
  end

  it "should parse a list" do
    p = pair_list [a, b, c, d], foo
    expect(Nydp::Pair.parse_list([a, b, c, d, dot, foo])).to eq p
  end
end
