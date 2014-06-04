class Nydp::Builtin::Cdr
  def invoke vm, args
    vm.push_arg args.car.cdr
  end
end
