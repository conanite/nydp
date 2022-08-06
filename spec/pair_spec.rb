require "spec_helper"

describe Nydp::Pair do
  let(:a)                { :a                  }
  let(:b)                { :b                  }
  let(:c)                { :c                  }
  let(:d)                { :d                  }
  let(:foo)              { :foo                }
  let(:dot)              { ".".to_sym          }

  describe "#map" do
    it "behaves like ruby #map" do
      list = pair_list [1,2,3]
      mapped = list.map { |x| x * 2 }
      expect(mapped).to eq pair_list([2,4,6])
    end
  end

  describe :== do
    it "should be true for two empty lists" do
      expect(Nydp::Pair.new(Nydp::NIL, Nydp::NIL)).to eq Nydp::Pair.new(Nydp::NIL, Nydp::NIL)

      expect(Nydp::Pair.new(nil, nil)).to eq Nydp::Pair.new(nil, nil)
    end

    it "there is no empty list, only NIL" do
      expect(Nydp::Pair.from_list([])).to eq Nydp::NIL
    end

    it "is false for (nil) == nil" do
      expect(Nydp::Pair.from_list([Nydp::NIL]) == Nydp::NIL).to eq false
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

  it "#to_ruby converts self and each element to ruby equivalent" do
    pair = pair_list [a, b, pair_list([a, b]), c, d]
    ruby = pair.to_ruby
    expect(ruby).to eq [:a, :b, [:a, :b], :c, :d]
  end

  it "#to_a converts to a ruby Array without converting elements" do
    pair = pair_list [a, b, pair_list([a, b]), c, d]
    ruby = pair.to_a
    expect(ruby).to eq [a, b, pair_list([a, b]), c, d]
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
