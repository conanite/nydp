require 'spec_helper'

describe Nydp::Symbol do
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

    expect(sym1).to eq sym2
    expect(sym1).not_to equal sym2
  end
end
