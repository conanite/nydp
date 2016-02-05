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
      expect(rhash.keys) .to eq [:boo]
    end

    it "converts ruby string key to nydp string key" do
      hash = Nydp::Hash.new
      hash[Nydp::StringAtom.new "boo"] = 42

      rhash = hash.to_ruby
      expect(rhash["boo"]).to eq 42
      expect(rhash.keys) .to eq ["boo"]
    end

    it "uses integer keys unconverted" do
      hash = Nydp::Hash.new
      hash[21] = 42

      rhash = hash.to_ruby
      expect(rhash[21]).to eq 42
      expect(rhash.keys) .to eq [21]
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

    describe "key?" do
      it "returns t when key is present" do
        h    = Nydp::Hash.new
        k    = sym "jerry"
        v    = 42
        h[k] = v

        Nydp::Builtin::HashKeyPresent.new(ns).invoke vm, pair_list([h, k])

        expect(vm.pop_arg).to eq Nydp.T
      end

      it "returns nil when key is absent" do
        h    = Nydp::Hash.new
        k    = sym "benjamin"

        Nydp::Builtin::HashKeyPresent.new(ns).invoke vm, pair_list([h, k])

        expect(vm.pop_arg).to eq Nydp.NIL
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
end
