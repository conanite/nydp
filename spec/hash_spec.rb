require "spec_helper"

describe Nydp::Hash do

  let(:vm) { Nydp::VM.new }

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
end
