class Nydp::Builtin::LoadTests
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    Nydp.loadall vm, vm.ns, Nydp.testfiles
    vm.push_arg Nydp::NIL
  end
end
