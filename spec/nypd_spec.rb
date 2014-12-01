require 'spec_helper'

describe Nydp do
  let(:root_ns)               { { } }
  let(:parser)                { Nydp::Parser.new(root_ns) }
  let(:vm)                    { Nydp::VM.new }

  def sym name
    Nydp::Symbol.mk name.to_sym, root_ns
  end

  def parse txt
    tokens = Nydp::Tokeniser.new txt
    expressions = []
    expr = parser.expression(tokens)
    while (expr != nil)
      expressions << expr
      expr = parser.expression(tokens)
    end
    expressions
  end

  def run txt
    Nydp.setup root_ns
    Nydp::StreamRunner.new(vm, root_ns, txt).run
  end

  it "should make a symbol from a string" do
    expect(run '(sym "the-family")').to eq sym(:"the-family")
  end

  it "should sum integers" do
    expect(run "(+ 1 2)").to eq 3
  end

  it "should add strings" do
    expect(run '(+ "hello" " " "world")').to eq "hello world"
  end

  it "should add Pairs" do
    expect(run "(+ '(a b) '(c d))").to eq Nydp::Pair.from_list([sym(:a), sym(:b), sym(:c), sym(:d)])
  end

  it "should add Pairs without recursing" do
    alist = Nydp::Pair.from_list([sym(:a), sym(:a)])
    blist = Nydp::Pair.from_list([sym(:b), sym(:b)])
    clist = Nydp::Pair.from_list([sym(:c), sym(:c)])
    dlist = Nydp::Pair.from_list([sym(:d), sym(:d)])
    expect(run "(+ '((a a) (b b)) '((c c) (d d)))").to eq Nydp::Pair.from_list([alist, blist, clist, dlist])
  end

  it "should diff integers" do
    expect(run "(- 144 121)").to eq 23
  end

  it "should multiply integers" do
    expect(run "(* 7 11)").to eq 77
  end

  it "should convert items to strings" do
    expect(run "(to-string 3.1415)").to eq "3.1415"
  end

  it "should compare integers" do
    expect(run "(> 13 17)").to eq Nydp.NIL
    expect(run "(> 29 23)").to eq Nydp.T
    expect(run "(< 13 17)").to eq Nydp.T
    expect(run "(< 29 23)").to eq Nydp.NIL
  end

  it "should execute an inline list function" do
    expected = Nydp::Pair.from_list (1..3).to_a
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

  it "should call functions in a chain" do
    f1 = "(fn (a b) (+ a b))"
    f2 = "(assign f1 #{f1})"
    f3 = "(fn (x y) (* x y))"
    f4 = "(assign f3 #{f3})"
    f5 = "(f1 (f3 6 6) (f3 8 8))"
    result = run "#{f2} #{f4} #{f5}"
    expect(result).to eq 100
  end

  it "should recurse without consuming extra memory" do
    program = "(assign f1 (fn (x acc) (cond (< x 1) (vm-info) (f1 (- x 1) (+ x acc))))) (f1 1000)"
    expected = parse "((contexts . 0) (instructions . 0) (args . 0))"
    expect(run program).to eq expected.first
  end

  describe :cond do
    it "should execute false conditionals" do
      cond = "(cond (> 31 37) 'foo 'bar)"
      expect(run cond).to eq sym(:bar)
    end

    it "should execute conditionals" do
      cond = "(cond (> 37 31) 'foo 'bar)"
      expect(run cond).to eq sym(:foo)
    end
  end

  describe "eval" do
    it "should eval the given expression and return the result" do
      code = "(eval '(+ 2 (* 3 5)))"
      expect(run code).to eq 17
    end
  end
end
