require 'spec_helper'

describe Nydp::VM do
  let(:vm) { Nydp::VM.new(ns) }

  def run txt
    Nydp.setup ns
    Nydp::Runner.new(vm, ns, Nydp::StringReader.new(txt)).run
  end

  describe "unhandled_error" do
    it "raises a helpful error" do
      error = nil
      begin
        run "(/ 10 0)"
      rescue StandardError => e
        error = e
      end

      expect(error).to be_a Nydp::Error
      expect(error.message).to eq "failed to eval (/ 10 0) from src (/ 10 0)"

      expect(error.cause).to be_a Nydp::InvocationFailed
      expect(error.cause.message).to eq "failed to execute invocation builtin//
  10
  0
source was (/ 10 0)
function name was /"

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
