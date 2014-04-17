class Nydp::Builtin::Car
  def invoke vm, arg
    vm.push_arg arg.car
  end
end
