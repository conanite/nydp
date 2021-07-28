require 'spec_helper'

describe Nydp::Symbol do
  let(:bar) { Nydp::Symbol.mk :BAR, ns }
  let(:foo) { Nydp::Symbol.mk :FOO, ns }
  let(:vm)  { Nydp::VM.new(ns)         }

  describe "#inspect" do
    it "wraps itself in pipe chars if empty" do
      sym = :""
      expect(sym._nydp_inspect).to eq "||"
    end
    it "wraps itself in pipe chars if nil" do
      sym = nil.to_s.to_sym
      expect(sym._nydp_inspect).to eq "||"
    end
    it "wraps itself in pipe chars if it has spaces" do
      sym = :"hello world"
      expect(sym._nydp_inspect).to eq "|hello world|"
    end
    it "wraps itself in pipe chars if it has pipe chars" do
      sym = :"hello|world"
      expect(sym._nydp_inspect).to eq '|hello\|world|'
    end
    it "wraps itself in pipe chars if it contains quote chars" do
      sym = :"hello 'world'"
      expect(sym._nydp_inspect).to eq "|hello 'world'|"
    end
    it "wraps itself in pipe chars if it contains doublequote chars" do
      sym = :'hello "world"'
      expect(sym._nydp_inspect).to eq '|hello "world"|'
    end
    it "wraps itself in pipe chars if it has other punctuation" do
      sym = :'hello,(world)'
      expect(sym._nydp_inspect).to eq '|hello,(world)|'
    end
  end

  it "returns a ruby symbol in #to_ruby" do
    sym = Nydp::Symbol.mk :foo, ns
    expect(sym.to_ruby).to eq :foo
  end

  it "should create a new symbol" do
    sym = Nydp::Symbol.mk :foo, ns
    expect(sym.name).to eq :foo
  end

  it "should consider symbols == when they share the same name" do
    ns1 = { }
    ns2 = { }

    sym1 = Nydp::Symbol.mk :baz, ns1
    sym2 = Nydp::Symbol.mk :baz, ns2

    expect(sym1.hash).to eq sym2.hash

    expect(sym1 ==     sym2).to eq true
    expect(sym1.eql?   sym2).to eq true
    expect(sym1.equal? sym2).to eq false
  end

  it "works with builtin greater-than when true" do
    f = Nydp::Builtin::GreaterThan.instance

    a = f.call foo, bar

    expect(a).to eq bar
  end

  it "works with builtin greater-than when false" do
    f = Nydp::Builtin::GreaterThan.instance

    a = f.call bar, foo

    expect(a).to eq Nydp::NIL
  end

  it "works with builtin less-than when true" do
    f = Nydp::Builtin::LessThan.instance

    a = f.call bar, foo

    expect(a).to eq foo
  end

  it "works with builtin less-than when false" do
    f = Nydp::Builtin::LessThan.instance

    a = f.call foo, bar

    expect(a).to eq Nydp::NIL
  end
end
