require "spec_helper"

describe ::Hash do

  describe "foreign hashes" do
    let(:ahash) { Hash.new }

    describe "hash set" do
      it "returns a new Nydp hash" do
        k    = :keysym
        v    = "foobar"
        a    = Nydp::Builtin::HashSet.instance.call ahash, k, v

        expect(ahash[:keysym]).      to eq "foobar"
        expect(ahash[:keysym].class).to eq String
        expect(ahash.keys).          to eq [:keysym]

        expect(a).to eq v
      end
    end

    describe "hash get" do
      it "converts ruby value to nydp value" do
        ahash[:keysym] = "avalue"

        a = Nydp::Builtin::HashGet.instance.call ahash, :keysym

        expect(a).to eq "avalue"
      end

      it "converts ruby nil to nydp value" do
        a = Nydp::Builtin::HashGet.instance.call ahash, :keysym

        expect(a).to eq nil
      end

      it "converts ruby true to nydp value" do
        ahash[:keysym] = true

        a = Nydp::Builtin::HashGet.instance.call ahash, :keysym

        expect(a).to eq true
      end
    end

    describe "key?" do
      it "returns t when key is present" do
        ahash[:simon] = 24

        a = Nydp::Builtin::HashKeyPresent.instance.call ahash, :simon

        expect(a).to eq true
      end

      it "returns nil when key is absent" do
        a = Nydp::Builtin::HashKeyPresent.instance.call ahash, :simon

        expect(a).to eq nil
      end
    end

    describe "hash keys" do
      it "returns a list of keys" do
        ahash[:k0] = 42
        ahash[:k1] = 84

        a = Nydp::Builtin::HashKeys.instance.call ahash

        expect(a).to eq pair_list [:k0, :k1]
      end
    end

    describe "hash-slice" do
      it "returns a new hash containing only the given keys from the old hash" do
        ahash[:k0] =  42
        ahash[:k1] =  84
        ahash[:k2] = 126

        a = Nydp::Builtin::HashSlice.instance.call ahash, pair_list([:k0, :k1])

        expect(a).to eq({ k0: 42, k1: 84 })
      end
    end
  end
end
