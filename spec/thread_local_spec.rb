require 'spec_helper'

describe Nydp do
  def run vm, txt
    Nydp::Runner.new(vm, ns, Nydp::StringReader.new(txt)).run
  end

  it "should isolate threadlocal values" do
    Nydp.setup ns

    vm0 = Nydp::VM.new
    vm1 = Nydp::VM.new


    run vm0, "(hash-set (thread-locals) 'testing (+ 1 2 3))"
    run vm1, "(hash-set (thread-locals) 'testing (+ 6 7 8))"

    val0 = run vm0, "(hash-get (thread-locals) 'testing)"
    val1 = run vm1, "(hash-get (thread-locals) 'testing)"

    expect(val0).to eq 6
    expect(val1).to eq 21
  end
end
