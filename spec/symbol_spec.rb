require 'spec_helper'

describe Nydp::Symbol do
  let(:bar) { Nydp::Symbol.mk :BAR, ns }
  let(:foo) { Nydp::Symbol.mk :FOO, ns }
  let(:vm)  { Nydp::VM.new             }

  it "returns a ruby symbol in #to_ruby" do
    sym = Nydp::Symbol.mk :foo, ns
    expect(sym.to_ruby).to eq :foo
  end

  it "should not recognise an unknown symbol" do
    sym = Nydp::Symbol.find :foo, ns
    expect(sym).to eq nil
  end

  it "should create a new symbol" do
    sym = Nydp::Symbol.mk :foo, ns
    expect(sym.name.should).to eq :foo
  end

  it "should not create a new symbol when the symbol already exists" do
    sym1 = Nydp::Symbol.mk :baz, ns
    sym2 = Nydp::Symbol.mk :baz, ns

    expect(sym1).to eq sym2
    expect(sym1).to equal sym2
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
    f = Nydp::Builtin::GreaterThan.new

    f.invoke vm, pair_list([foo, bar])

    expect(vm.args.pop).to eq Nydp.T
  end

  it "works with builtin greater-than when false" do
    f = Nydp::Builtin::GreaterThan.new

    f.invoke vm, pair_list([bar, foo])

    expect(vm.args.pop).to eq Nydp.NIL
  end

  it "works with builtin less-than when true" do
    f = Nydp::Builtin::LessThan.new

    f.invoke vm, pair_list([bar, foo])

    expect(vm.args.pop).to eq Nydp.T
  end

  it "works with builtin less-than when false" do
    f = Nydp::Builtin::LessThan.new

    f.invoke vm, pair_list([foo, bar])

    expect(vm.args.pop).to eq Nydp.NIL
  end

end
