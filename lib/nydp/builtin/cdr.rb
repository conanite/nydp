class Nydp::Builtin::Cdr
  def invoke vm, arg
    vm.push_arg arg.car.cdr
  end
end
