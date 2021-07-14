require "spec_helper"

describe Nydp::Hash do
  let(:vm) { Nydp::VM.new(ns) }

  describe "foreign hashes" do
    let(:ahash) { Hash.new }

    describe "hash set" do
      it "returns a new Nydp hash" do
        k    = Nydp::Symbol.mk "keysym", ns
        v    = "foobar"
        args = pair_list [ahash, k, v]
        a    = Nydp::Builtin::HashSet.instance.invoke vm, args

        expect(ahash[:keysym]).      to eq "foobar"
        expect(ahash[:keysym].class).to eq String
        expect(ahash.keys).          to eq [:keysym]

        expect(a).to eq v
      end
    end

    describe "hash get" do
      it "converts ruby value to nydp value" do
        ahash[:keysym] = "avalue"
        k              = sym("keysym")
        args           = [ ahash, k ]

        a = Nydp::Builtin::HashGet.instance.invoke vm, pair_list(args)

        expect(a).to eq "avalue"
      end

      it "converts ruby nil to nydp value" do
        k              = sym("keysym")
        args           = [ ahash, k ]

        a = Nydp::Builtin::HashGet.instance.invoke vm, pair_list(args)

        expect(a).to eq Nydp::NIL
      end

      it "converts ruby true to nydp value" do
        ahash[:keysym] = true
        k              = sym("keysym")
        args           = [ ahash, k ]

        a = Nydp::Builtin::HashGet.instance.invoke vm, pair_list(args)

        expect(a).to eq Nydp::T
      end
    end

    describe "key?" do
      it "returns t when key is present" do
        ahash[:simon] = 24
        k             = sym("simon")
        args          = [ ahash, k ]

        a = Nydp::Builtin::HashKeyPresent.instance.invoke vm, pair_list(args)

        expect(a).to eq Nydp::T
      end

      it "returns nil when key is absent" do
        k             = sym("simon")
        args          = [ ahash, k ]

        a = Nydp::Builtin::HashKeyPresent.instance.invoke vm, pair_list(args)

        expect(a).to eq Nydp::NIL
      end
    end

    describe "hash keys" do
      it "returns a list of keys" do
        ahash[:k0] = 42
        ahash[:k1] = 84
        args       = [ahash]

        a = Nydp::Builtin::HashKeys.instance.invoke vm, pair_list(args)

        expect(a).to eq pair_list [sym("k0"), sym("k1")]
      end
    end

    describe "hash-slice" do
      it "returns a new hash containing only the given keys from the old hash" do
        ahash[:k0] = 42
        ahash[:k1] = 84
        args       = [ahash, pair_list([sym("k0"), sym("k1")])]

        a = Nydp::Builtin::HashSlice.instance.invoke vm, pair_list(args)

        expect(a).to eq({ k0: 42, k1: 84 })
      end
    end
  end
end
