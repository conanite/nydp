require 'spec_helper'

describe Nydp do
  def run vm, txt
    Nydp::Runner.new(vm, ns, Nydp::StringReader.new(txt)).run
  end

  it "should isolate threadlocal values" do

    # note : this test is mostly on principle, it can't guarantee
    # correctness insofar as it doesn't guarantee that the threads
    # run in a way such that they would interfere with each other
    # if thread_locals were not used...

    Nydp.setup ns

    vm = Nydp::VM.new ns

    t0 = Thread.new {
      run vm, "(hash-set (thread-locals) 'testing (+ 1 2 3))"
      sleep 0.1
      run vm, "(hash-get (thread-locals) 'testing)"
    }

    t1 = Thread.new {
      run vm, "(hash-set (thread-locals) 'testing (+ 6 7 8))"
      run vm, "(hash-get (thread-locals) 'testing)"
    }

    t0.join
    t1.join

    val0 = t0.value
    val1 = t1.value

    expect(val0).to eq 6
    expect(val1).to eq 21
  end
end
