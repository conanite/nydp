require 'spec_helper'

describe Nydp::Date do

  let(:timef) { Nydp::Builtin::Time.instance }

  it "r2n does not convert ruby Time" do
    rd = Time.now
    nd = Nydp.r2n rd

    expect(nd).to be_a Time
    expect(nd).to eq rd
  end

  it "creates a new Time instance" do
    nd = timef.call 2015, 11, 18, 18, 30, 17
    expect(nd).to be_a Time
    expect(nd).to eq Time.new(2015, 11, 18, 18, 30, 17)
  end

  it "creates a new Time instance for #now" do
    t0 = Time.now
    nd = timef.call
    t1 = Time.now
    expect(nd).to be_a Time
    expect(nd).to be_between(t0, t1)
  end

  it "creates a new Time instance for #now plus offset" do
    t0 = Time.now
    nd = timef.call 3.14
    t1 = Time.now
    expect(nd).to be_a Time
    expect(nd).to be_between((t0 + 3.14), (t1 + 3.14))
  end

  it "creates a new Time instance for a given Date" do
    nd = timef.call Date.parse "2006-06-21"
    expect(nd).to be_a Time
    expect(nd).to eq Time.new(2006, 6, 21)
  end
end
