class Nydp::Builtin::Sqrt
  def invoke vm, args
    vm.push_arg Math.sqrt args.car
  end
end
