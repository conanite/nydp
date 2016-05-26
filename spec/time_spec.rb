require 'spec_helper'

describe Nydp::Date do

  let(:ns)    { { }                          }
  let(:vm)    { Nydp::VM.new(ns)             }
  let(:timef) { Nydp::Builtin::Time.instance }

  it "r2n does not convert ruby Time" do
    rd = Time.now
    nd = Nydp.r2n rd, ns

    expect(nd).to be_a Time
    expect(nd).to eq rd
  end

  it "creates a new Time instance" do
    timef.invoke vm, Nydp::Pair.from_list([2015, 11, 18, 18, 30, 17])
    nd = vm.args.pop
    expect(nd).to be_a Time
    expect(nd).to eq Time.new(2015, 11, 18, 18, 30, 17)
  end

  it "creates a new Time instance for #now" do
    t0 = Time.now
    timef.invoke_1 vm
    nd = vm.args.pop
    t1 = Time.now
    expect(nd).to be_a Time
    expect(nd).to be_between(t0, t1)
  end

  it "creates a new Time instance for #now plus offset" do
    t0 = Time.now
    timef.invoke_2 vm, 3.14
    nd = vm.args.pop
    t1 = Time.now
    expect(nd).to be_a Time
    expect(nd).to be_between((t0 + 3.14), (t1 + 3.14))
  end

  it "creates a new Time instance for a given Date" do
    timef.invoke_2 vm, Nydp::Date.new(Date.parse "2006-06-21")
    nd = vm.args.pop
    expect(nd).to be_a Time
    expect(nd).to eq Time.new(2006, 6, 21)
  end
end
