require 'spec_helper'

describe Nydp::VM do
  let(:ns) { { } }
  let(:vm) { Nydp::VM.new(ns) }

  def run txt
    Nydp.setup ns
    Nydp::ExplodeRunner.new(vm, ns, Nydp::StringReader.new(txt)).run
  end

  describe "unhandled_error" do
    it "raises a helpful error" do
      error = nil
      begin
        run "dflkjdgjeirgjeoi"
      rescue Exception => e
        error = e
      end

      expect(error).to be_a Nydp::Error
      expect(error.message).to eq "failed to eval dflkjdgjeirgjeoi"

      expect(error.cause).to be_a RuntimeError
      expect(error.cause.message).to eq "unbound symbol: dflkjdgjeirgjeoi"

      expect(vm.unhandled_error).to eq nil
    end

    it "recovers quickly from an error" do
      begin
        run "dflkjdgjeirgjeoi"
      rescue
      end

      expect(vm.unhandled_error).to eq nil

      expect(run "(+ 2 3 4)").to eq 9
    end
  end
end
