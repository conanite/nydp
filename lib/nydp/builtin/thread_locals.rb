class Nydp::Builtin::ThreadLocals
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg vm.locals
  end
end
