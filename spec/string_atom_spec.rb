require "spec_helper"

describe Nydp::StringAtom do
  let(:bar) { Nydp::StringAtom.new "BAR" }
  let(:foo) { Nydp::StringAtom.new "FOO" }
  let(:vm)  { Nydp::VM.new               }

  it "returns its string in #to_ruby" do
    s = Nydp::StringAtom.new "harrypotter"
    expect(s.to_ruby).to eq "harrypotter"
    expect(s.to_ruby.class).to eq String
  end

  it "works with builtin greater-than when true" do
    f = Nydp::Builtin::GreaterThan.new

    f.invoke vm, pair_list([foo, bar])

    expect(vm.pop_arg).to eq Nydp.T
  end

  it "works with builtin greater-than when false" do
    f = Nydp::Builtin::GreaterThan.new

    f.invoke vm, pair_list([bar, foo])

    expect(vm.pop_arg).to eq Nydp.NIL
  end

  it "works with builtin less-than when true" do
    f = Nydp::Builtin::LessThan.new

    f.invoke vm, pair_list([bar, foo])

    expect(vm.pop_arg).to eq Nydp.T
  end

  it "works with builtin less-than when false" do
    f = Nydp::Builtin::LessThan.new

    f.invoke vm, pair_list([foo, bar])

    expect(vm.pop_arg).to eq Nydp.NIL
  end
end
