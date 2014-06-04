class Nydp::Builtin::Car
  def invoke vm, args
    vm.push_arg args.car.car
  end
end
