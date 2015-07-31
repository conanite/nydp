class Nydp::Builtin::LoadTests
  include Nydp::Builtin::Base

  def initialize ns
    @ns = ns
  end

  def builtin_invoke vm, args
    Nydp.loadall vm, @ns, Nydp.testfiles
    vm.push_arg Nydp.NIL
  end
end
