class Nydp::Builtin::LoadTests
  def initialize ns
    @ns = ns
  end
  def invoke vm, args
    Nydp.loadall vm, @ns, Nydp.testfiles
    vm.push_arg Nydp.NIL
  end
end
