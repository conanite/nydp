class Nydp::Builtin::ThreadLocals
  include Nydp::Helper

  def invoke vm, args
    vm.push_arg vm.locals
  end
end
