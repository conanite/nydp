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
      proc = Proc.new { run "dflkjdgjeirgjeoi" }
      msg  = "failed to eval dflkjdgjeirgjeoi\nerror was   unbound symbol: dflkjdgjeirgjeoi"
      expect(proc).to raise_error RuntimeError, msg
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
