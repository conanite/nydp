require "spec_helper"

describe Nydp::StringAtom do
  let(:bar) { "BAR" }
  let(:foo) { "FOO" }

  it "is not equal to a symbol with the same represenation" do
    string = "harrypotter"
    symbol = :harrypotter
    compare = symbol.to_s
    expect(string == compare).to eq true
    expect(string == symbol) .to eq false
  end

  it "is not equal to a list with the same represenation" do
    string = '("FOO" "BAR")'
    list   = Nydp::Pair.from_list [foo, bar]
    compare = list.to_s
    expect(string == compare).to eq true
    expect(string == list)   .to eq false
  end

  it "returns its string in #to_ruby" do
    s = Nydp::StringAtom.new "harrypotter"
    expect(s.to_ruby).to eq "harrypotter"
    expect(s.to_ruby.class).to eq String
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
