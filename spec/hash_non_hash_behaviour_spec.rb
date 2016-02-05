require "spec_helper"

describe Nydp::Hash do
  let(:vm) { Nydp::VM.new }

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

  describe "unfriendly non-hash" do
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
