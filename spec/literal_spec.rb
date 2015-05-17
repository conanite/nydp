require 'spec_helper'

describe Nydp::Literal do
  it "returns a ruby symbol in #to_ruby" do
    sym = Nydp::Symbol.mk :foo, ns
    lit = Nydp::Literal.new sym
    expect(lit.to_ruby).to eq :foo
  end
end
