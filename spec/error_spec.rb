require 'spec_helper'

describe Nydp::VM do
  let(:ns) { { } }
  let(:vm) { Nydp::VM.new }

  def run txt
    Nydp.setup ns
    Nydp::ExplodeRunner.new(vm, ns, Nydp::StringReader.new(txt)).run
  end

  describe "unhandled_error" do
    it "raises a helpful error" do
      proc = Proc.new { run "dflkjdgjeirgjeoi" }
      msg  = "failed to eval dflkjdgjeirgjeoi\nerror was   unbound symbol: dflkjdgjeirgjeoi"
      expect(proc).to raise_error RuntimeError, msg
    end
  end
end
