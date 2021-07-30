require "spec_helper"

describe ::Hash do

  describe "friendly non-hashes" do
    let(:ahash) { TestThing.new 123, "hello there", "private" }

    describe "hash get" do
      it "returns a plain number" do
        a = Nydp::Builtin::HashGet.instance.call ahash, :a
        expect(a).to eq 123
      end

      it "converts ruby value to nydp value" do
        a = Nydp::Builtin::HashGet.instance.call ahash, :b
        expect(a).to eq "hello there"
      end

      it "converts string keys to method names" do
        a = Nydp::Builtin::HashGet.instance.call ahash, "b"
        expect(a).to eq "hello there"
      end

      it "returns nil for unavailable methods" do
        a = Nydp::Builtin::HashGet.instance.call ahash, :c
        expect(a).to eq Nydp::NIL
      end
    end
  end

  describe "unfriendly non-hash" do
    let(:ahash) { "this here ain't no hash, hombre" }

    def cleanup_err_msg txt
      txt.gsub(/at \/.*:in `builtin_invoke'/, '<error info>')
    end

    describe "hash set" do
      it "does nothing, returns its value" do
        k    = Nydp::Symbol.mk "keysym", ns
        v    = "foobar"

        begin
          Nydp::Builtin::HashSet.instance.call ahash, k, v
        rescue StandardError => e
          error = e
        end

        expect(cleanup_err_msg error.message).to eq "Called builtin/hash-set
with args
  \"this here ain't no hash, hombre\"
  keysym
  \"foobar\""

        expect(cleanup_err_msg error.cause.message).to eq "_nydp_get : not settable: keysym on String"
      end
    end

    describe "hash get" do
      it "converts ruby value to nydp value" do
        begin
          Nydp::Builtin::HashGet.instance.call ahash, :keysym
        rescue StandardError => e
          error = e
        end

        expect(cleanup_err_msg error.message).to eq "Called builtin/hash-get
with args
  \"this here ain't no hash, hombre\"
  keysym"

        expect(cleanup_err_msg error.cause.message).to eq "_nydp_get : not gettable: keysym on String"
      end
    end
  end
end
