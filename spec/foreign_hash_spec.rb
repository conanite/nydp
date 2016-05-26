require "spec_helper"

describe Nydp::Hash do
  let(:vm) { Nydp::VM.new(ns) }

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

        expect(vm.args.pop).to eq v
      end
    end

    describe "hash get" do
      it "converts ruby value to nydp value" do
        ahash[:keysym] = "avalue"
        k              = sym("keysym")
        args           = [ ahash, k ]

        Nydp::Builtin::HashGet.new.invoke vm, pair_list(args)

        expect(vm.args.pop).to eq Nydp::StringAtom.new("avalue")
      end

      it "converts ruby nil to nydp value" do
        k              = sym("keysym")
        args           = [ ahash, k ]

        Nydp::Builtin::HashGet.new.invoke vm, pair_list(args)

        expect(vm.args.pop).to eq Nydp::NIL
      end

      it "converts ruby true to nydp value" do
        ahash[:keysym] = true
        k              = sym("keysym")
        args           = [ ahash, k ]

        Nydp::Builtin::HashGet.new.invoke vm, pair_list(args)

        expect(vm.args.pop).to eq Nydp::T
      end
    end

    describe "key?" do
      it "returns t when key is present" do
        ahash[:simon] = 24
        k             = sym("simon")
        args          = [ ahash, k ]

        Nydp::Builtin::HashKeyPresent.new.invoke vm, pair_list(args)

        expect(vm.args.pop).to eq Nydp::T
      end

      it "returns nil when key is absent" do
        k             = sym("simon")
        args          = [ ahash, k ]

        Nydp::Builtin::HashKeyPresent.new.invoke vm, pair_list(args)

        expect(vm.args.pop).to eq Nydp::NIL
      end
    end

    describe "hash keys" do
      it "returns a list of keys" do
        ahash[:k0] = 42
        ahash[:k1] = 84
        args       = [ahash]

        Nydp::Builtin::HashKeys.new.invoke vm, pair_list(args)

        expect(vm.args.pop).to eq pair_list [sym("k0"), sym("k1")]
      end
    end
  end
end
