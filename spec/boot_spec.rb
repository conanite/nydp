require 'spec_helper'

describe Nydp do
  let(:vm)                    { Nydp::VM.new }

  before {
    Nydp.setup ns
    boot_path = File.expand_path File.join File.expand_path(File.dirname(__FILE__)), '../lib/lisp/boot.nydp'
    reader = Nydp::StreamReader.new(File.new(boot_path))
    Nydp::Runner.new(vm, ns, reader).run
  }

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
    Nydp::Runner.new(vm, ns, Nydp::StringReader.new(txt)).run
  end

  describe :let do
    it "should create an inner scope with a single variable" do
      lisp = "(def x+3*z (x) (let y 3 (fn (z) (* (+ x y) z)))) ((x+3*z 2) 5)"
      result = run lisp
      expect(result).to eq 25
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
      expect(result).to eq parse "((fn (ora-1) (cond ora-1 ora-1 ((fn (ora-2) (cond ora-2 ora-2 ((fn (ora-3) (cond ora-3 ora-3 nil)) c))) b))) a)"
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
