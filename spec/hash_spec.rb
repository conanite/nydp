require "spec_helper"

describe Nydp::Hash do

  let(:vm) { Nydp::VM.new(ns) }

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
      hash["boo"] = 42

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
        h  = Nydp::Builtin::Hash.instance.call
        expect(h).to be_a ::Hash
      end
    end

    describe "hash set" do
      it "sets a value on a hash" do
        h    = Nydp::Hash.new
        a    = Nydp::Builtin::HashSet.instance.call h, :keysym, 42

        expect(h.keys).    to eq [:keysym]
        expect(h[:keysym]).to eq 42
        expect(a).         to eq 42
      end
    end

    describe "hash get" do
      it "gets a value from a hash" do
        h    = Nydp::Hash.new
        k    = :keysym
        v    = 42
        h[k] = v

        a    = Nydp::Builtin::HashGet.instance.call h, k
        expect(a).to eq v
      end
    end

    describe "key?" do
      it "returns t when key is present" do
        h    = Nydp::Hash.new
        k    = sym "jerry"
        v    = 42
        h[k] = v

        a = Nydp::Builtin::HashKeyPresent.instance.call h, k

        expect(a).to eq Nydp::T
      end

      it "returns nil when key is absent" do
        h    = Nydp::Hash.new
        k    = sym "benjamin"

        a = Nydp::Builtin::HashKeyPresent.instance.call h, k

        expect(a).to eq Nydp::NIL
      end
    end

    describe "hash keys" do
      it "returns a list of keys" do
        h    = Nydp::Hash.new
        h[sym "k0"] = 42
        h[sym "k1"] = 84

        a    = Nydp::Builtin::HashKeys.instance.call h
        expect(a).to eq pair_list [sym("k0"), sym("k1")]
      end
    end
  end

  describe "get/set nil" do
    let(:ahash) { Nydp::NIL }

    describe "hash set" do
      it "does nothing, returns its value" do
        k    = Nydp::Symbol.mk "keysym", ns
        v    = "foobar"
        a    = Nydp::Builtin::HashSet.instance.call ahash, k, v

        expect(ahash).     to eq Nydp::NIL
        expect(a).         to eq v
      end
    end

    describe "hash get" do
      it "converts ruby value to nydp value" do
        k    = Nydp::Symbol.mk "keysym", ns

        a = Nydp::Builtin::HashGet.instance.call ahash, k

        expect(a).to eq Nydp::NIL
      end
    end
  end

  describe "hash-slice" do
    it "returns a new hash containing only the given keys from the old hash" do
      hash = Nydp::Hash.new
      sfoo = sym "foo"
      sbar = sym "bar"
      syak = sym "yak"
      szeb = sym "zeb"

      h = Nydp::Hash.new

      h[sfoo] = 16
      h[sbar] = 42
      h[szeb] = 99

      a = Nydp::Builtin::HashSlice.instance.call h, pair_list([sbar, syak, szeb])

      expect(a).to eq({ sbar => 42, szeb => 99 })
    end
  end
end
