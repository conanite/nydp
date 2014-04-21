require 'spec_helper'

describe Nydp do
  let(:root_ns)               { { } }
  let(:parser)                { Nydp::Parser.new(root_ns) }
  let(:vm)                    { Nydp::VM.new }

  def parse txt
    tokens = Nydp::Tokeniser.new txt
    expressions = []
    expr = parser.expression(tokens)
    while (expr != nil) && Nydp.NIL.isnt?(expr)
      puts "read #{expr}"
      expressions << expr
      expr = parser.expression(tokens)
    end
    expressions
  end

  def run txt
    Nydp.setup root_ns
    expressions = parse(txt)
    result = nil
    expressions.each do |expr|
      result = Nydp.compile_and_eval vm, expr
    end
    result
  end

  it "should sum integers" do
    expect(run "(+ 1 2)").to eq 3
  end

  it "should multiply integers" do
    expect(run "(* 7 11)").to eq 77
  end

  it "should execute an inline list function" do
    expected = Nydp::Pair.from_list (1..3).map { |x| Nydp::Literal.new x }
    expect(run "((fn a a) 1 2 3)").to eq expected
  end

  it "should execute an inline sum function" do
    expect(run "((fn (a b) (+ a b)) 9 16)").to eq 25
  end

  it "should assign a function to a global variable and execute it" do
    f1 = "(fn (a b) (+ a b))"
    f2 = "(assign f1 #{f1})"
    f3 = "(f1 36 64)"
    result = run "#{f2} #{f3}"
    expect(result).to eq 100
  end
end
