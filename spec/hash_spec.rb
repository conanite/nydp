require "spec_helper"

describe Nydp::Hash do

  class TestThing
    attr_accessor :a, :b, :c
    def initialize a, b, c
      @a, @b, @c = a, b, c
    end

    def inspect
      "(TestThing #{a.inspect} #{b.inspect})"
    end

    def _nydp_safe_methods ; %i{ a b } ; end
  end

  let(:vm) { Nydp::VM.new }

  describe "#to_ruby" do
    it "converts ruby symbol key to nydp symbol key" do
      hash = Nydp::Hash.new
      hash[sym "boo"] = 42

      rhash = hash.to_ruby
      expect(rhash[:boo]).to eq 42
    end

    it "converts ruby string key to nydp string key" do
      hash = Nydp::Hash.new
      hash[Nydp::StringAtom.new "boo"] = 42

      rhash = hash.to_ruby
      expect(rhash["boo"]).to eq 42
    end

    it "uses integer keys unconverted" do
      hash = Nydp::Hash.new
      hash[21] = 42

      rhash = hash.to_ruby
      expect(rhash[21]).to eq 42
    end
  end

  describe "hash merge" do
    it "merges two hashes" do
      ns = { }
      Nydp.setup(ns)
      hash_0 = { foo: 12, bar: 34}
      hash_1 = { foo: 49, zap: 87}

      merged = Nydp.apply_function ns, "hash-merge", hash_0, hash_1

      expect(merged).to eq({ foo: 49, bar: 34, zap: 87 })
    end
  end

  describe "nydp hashes" do
    describe "new hash" do
      it "returns a new Nydp hash" do
        Nydp::Builtin::Hash.new.invoke vm, Nydp.NIL
        h = vm.pop_arg
        expect(h).to be_a Nydp::Hash
      end
    end

    describe "hash set" do
      it "sets a value on a hash" do
        h    = Nydp::Hash.new
        k    = sym "keysym"
        v    = 42
        args = Nydp::Pair.from_list([h, k, v])
        Nydp::Builtin::HashSet.new.invoke vm, args

        expect(h.keys).    to eq [k]
        expect(h[k]).      to eq v
        expect(vm.pop_arg).to eq v
      end
    end

    describe "hash get" do
      it "gets a value from a hash" do
        h    = Nydp::Hash.new
        k    = sym "keysym"
        v    = 42
        h[k] = v

        args = Nydp::Pair.from_list([h, k])
        Nydp::Builtin::HashGet.new(ns).invoke vm, args
        expect(vm.pop_arg).to eq v
      end
    end

    describe "hash keys" do
      it "returns a list of keys" do
        h    = Nydp::Hash.new
        h[sym "k0"] = 42
        h[sym "k1"] = 84

        args = Nydp::Pair.from_list([h])
        Nydp::Builtin::HashKeys.new(ns).invoke vm, args
        expect(vm.pop_arg).to eq pair_list [sym("k0"), sym("k1")]
      end
    end
  end

  describe "foreign hashes" do
    let(:ahash) { Hash.new }

    describe "hash set" do
      it "returns a new Nydp hash" do
        k    = Nydp::Symbol.mk "keysym", ns
        v    = Nydp::StringAtom.new "foobar"
        args = pair_list [ahash, k, v]
        Nydp::Builtin::HashSet.new.invoke vm, args

        expect(ahash[:keysym]).      to eq "foobar"
        expect(ahash[:keysym].class).to eq String
        expect(ahash.keys).          to eq [:keysym]

        expect(vm.pop_arg).to eq v
      end
    end

    describe "hash get" do
      it "converts ruby value to nydp value" do
        ahash[:keysym] = "avalue"
        k              = sym("keysym")
        args           = [ ahash, k ]

        Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)

        expect(vm.pop_arg).to eq Nydp::StringAtom.new("avalue")
      end

      it "converts ruby nil to nydp value" do
        k              = sym("keysym")
        args           = [ ahash, k ]

        Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)

        expect(vm.pop_arg).to eq Nydp.NIL
      end

      it "converts ruby true to nydp value" do
        ahash[:keysym] = true
        k              = sym("keysym")
        args           = [ ahash, k ]

        Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)

        expect(vm.pop_arg).to eq Nydp.T
      end
    end

    describe "hash keys" do
      it "returns a list of keys" do
        ahash[:k0] = 42
        ahash[:k1] = 84
        args       = [ahash]

        Nydp::Builtin::HashKeys.new(ns).invoke vm, pair_list(args)

        expect(vm.pop_arg).to eq pair_list [sym("k0"), sym("k1")]
      end
    end
  end

  describe "get/set nil" do
    let(:ahash) { Nydp.NIL }

    describe "hash set" do
      it "does nothing, returns its value" do
        k    = Nydp::Symbol.mk "keysym", ns
        v    = Nydp::StringAtom.new "foobar"
        args = pair_list [ahash, k, v]
        Nydp::Builtin::HashSet.new.invoke vm, args

        expect(ahash).     to eq Nydp.NIL
        expect(vm.pop_arg).to eq v
      end
    end

    describe "hash get" do
      it "converts ruby value to nydp value" do
        k    = Nydp::Symbol.mk "keysym", ns
        args           = [ ahash, k ]

        Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)

        expect(vm.pop_arg).to eq Nydp.NIL
      end
    end
  end

  describe "friendly non-hashes" do
    let(:ahash) { TestThing.new 123, "hello there", "private" }

    describe "hash get" do
      it "returns a plain number" do
        k      = Nydp::Symbol.mk "a", ns
        args   = [ ahash, k ]

        Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)
        expect(vm.pop_arg).to eq 123
      end

      it "converts ruby value to nydp value" do
        k      = Nydp::Symbol.mk "b", ns
        args   = [ ahash, k ]

        Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)
        expect(vm.pop_arg).to eq Nydp::StringAtom.new("hello there")
      end

      it "converts string keys to method names" do
        k      = Nydp::StringAtom.new "b"
        args   = [ ahash, k ]

        Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)
        expect(vm.pop_arg).to eq Nydp::StringAtom.new("hello there")
      end

      it "returns nil for unavailable methods" do
        k      = Nydp::Symbol.mk "c", ns
        args   = [ ahash, k ]

        Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)
        expect(vm.pop_arg).to eq Nydp.NIL
      end
    end
  end

  describe "non-hash" do
    let(:ahash) { Nydp::StringAtom.new "this here ain't no hash, hombre" }

    describe "hash set" do
      it "does nothing, returns its value" do
        k    = Nydp::Symbol.mk "keysym", ns
        v    = Nydp::StringAtom.new "foobar"
        args = pair_list [ahash, k, v]

        begin
          Nydp::Builtin::HashSet.new.invoke vm, args
        rescue Exception => e
          error = e
        end

        expect(error.message.gsub(/at \/.*:in `builtin_invoke'/, '<error info>')).to eq "Called builtin/hash-set
with args (\"this here ain't no hash, hombre\" keysym \"foobar\")
raised
  hash-set: Not a hash: Nydp::StringAtom
<error info>"
      end
    end

    describe "hash get" do
      it "converts ruby value to nydp value" do
        k      = Nydp::Symbol.mk "keysym", ns
        args   = [ ahash, k ]

        begin
          Nydp::Builtin::HashGet.new(ns).invoke vm, pair_list(args)
        rescue Exception => e
          error = e
        end

        expect(error.message.gsub(/at \/.*:in `ruby_call'/, '<error info>')).to eq "Called builtin/hash-get
with args (\"this here ain't no hash, hombre\" keysym)
raised
  hash-get: Not a hash: Nydp::StringAtom
<error info>"
      end
    end
  end
end
