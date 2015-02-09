require 'spec_helper'

describe Nydp do
  let(:ns)                    { { } }
  let(:vm)                    { Nydp::VM.new }

  before {
    Nydp.setup ns
    boot_path = File.expand_path File.join File.expand_path(File.dirname(__FILE__)), '../lib/lisp/boot.nydp'
    Nydp::StreamRunner.new(vm, ns, File.new(boot_path)).run
  }

  def sym name
    Nydp::Symbol.mk name.to_sym, ns
  end

  def list *things
    Nydp::Pair.from_list things.map { |thing|
      case thing
      when Symbol
        sym(thing)
      when Array
        list(*thing)
      else
        thing
      end
    }
  end

  def run txt
    Nydp::StreamRunner.new(vm, ns, txt).run
  end

  it "should map a function over a list of numbers" do
    expect(run "(map (fn (x) (* x x)) '(1 2 3))").to eq Nydp::Pair.from_list [1, 4, 9]
  end

  describe "quasiquote" do
    it "should quasiquote a standalone item" do
      expect(run "`a").to eq sym(:a)
    end

    it "should quasiquote a plain list" do
      expect(run "`(a b c)").to eq list :a, :b, :c
    end

    it "should quasiquote a plain list with a variable substitution" do
      expect(run "(assign b 10) `(a ,b c)").to eq list :a, 10, :c
    end

    it "should quasiquote a plain list with a list-variable substitution" do
      expect(run "(assign b '(1 2 3)) `(a ,@b c)").to eq list :a, 1, 2, 3, :c
    end

    it "should quasiquote a plain list with a list-variable substitution at the end" do
      expect(run "(assign b '(1 2 3)) `(a ,b ,@b)").to eq list :a, [1,2,3], 1, 2, 3
    end

    it "should quasiquote a plain list with a list-variable substitution at the end" do
      expect(run "(assign d '(1 2 3)) (assign g '(x y z)) `(a (b c ,d (e f ,@g)))").to eq list :a, [:b, :c, [1, 2, 3], [:e, :f, :x, :y, :z]]
    end
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
      expect(result).to eq list :poo, :x, :"*", :x, :x, 1, 2, 3
    end
  end

  describe :and do
    it "should produce some nested conds" do
      result = run "(pre-compile '(and a b c))"
      expect(result).to eq list :cond, :a, [:cond, :b, :c]
    end
  end

  describe :w_uniq do
    it "should handle single-var case" do
      result = run "(reset-uniq-counter) (pre-compile '(w/uniq a foo))"
      expect(result).to eq list [:fn, [:a], :foo], [:uniq, [:quote, :a]]
    end
  end

  describe :or do
    it "should produce some nested conds" do
      result = run "(reset-uniq-counter) (pre-compile '(or a b c))"
      expect(result.to_s).to eq "((fn (ora-1) (cond ora-1 ora-1 ((fn (ora-2) (cond ora-2 ora-2 ((fn (ora-3) (cond ora-3 ora-3 nil)) c))) b))) a)"
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
