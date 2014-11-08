require 'spec_helper'

describe Nydp do
  let(:ns)                    { { } }
  let(:vm)                    { Nydp::VM.new }

  before {
    Nydp.setup ns
    boot_path = File.expand_path File.join File.expand_path(File.dirname(__FILE__)), '../lib/lisp/boot.nydp'
    Nydp::Runner.new(vm, ns, File.new(boot_path)).run
  }

  def sym name
    Nydp::Symbol.mk name.to_sym, ns
  end

  def run txt
    Nydp::Runner.new(vm, ns, txt).run
  end

  it "should map a function over a list of numbers" do
    expect(run "(map (fn (x) (* x x)) '(1 2 3))").to eq Nydp::Pair.from_list [1, 4, 9]
  end

  describe "pairs" do
    it "should break a list into pairs" do
      result   = run "(pairs '(1 a 2 b 3 c))"
      expected = run "'((1 a) (2 b) (3 c))"
      expect(result).to eq expected
    end
  end

  describe :let do
    it "should create an inner scope with a single variable" do
      lisp = "(def x+3*z (x) (let y 3 (fn (z) (* (+ x y) z)))) ((x+3*z 2) 5)"
      result = run lisp
      expect(result).to eq 25
    end
  end

  describe :flatten do
    it "should return a flat list of things" do
      lisp = "(flatten '((poo (x) (* x x)) (1 2 3)))"
      result = run lisp
      expect(result).to eq Nydp::Pair.from_list [(sym :poo), (sym :x), (sym :"*"), (sym :x), (sym :x), 1, 2, 3]
    end
  end

  describe :join do
    it "should join a list of strings together" do
      joining = %{(joinstr "" '("foo" "bar" "bax"))}
      expect(run joining).to eq "foobarbax"
    end

    it "should join a list of things together as a string" do
      expect(run %{(joinstr " - " '(1 2 3))}).to eq "1 - 2 - 3"
    end
  end
end
