class Nydp::Builtin::Inspect
  def invoke vm, args
    vm.push_arg args.car.inspect
  end
end
