require 'spec_helper'

describe Nydp do
  let(:root_ns)               { { } }
  let(:parser)                { Nydp::Parser.new(root_ns) }
  let(:vm)                    { Nydp::VM.new }

  def parse txt
    parser.expression(Nydp::Tokeniser.new txt)
  end

  def run txt
    Nydp.setup root_ns
    Nydp.compile_and_eval vm, parse(txt)
  end

  it "should sum integers" do
    expect(run "(+ 1 2)").to eq 3
  end

  it "should execute an inline list function" do
    expected = Nydp::Pair.from_list (1..3).map { |x| Nydp::Literal.new x }
    expect(run "((fn a a) 1 2 3)").to eq expected
  end

  it "should execute an inline sum function" do
    expect(run "((fn (a b) (+ a b)) 9 16)").to eq 25
  end
end
