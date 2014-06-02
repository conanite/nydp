class Nydp::Builtin::CdrSet
  def invoke vm, args
    pair = args.car
    arg = args.cdr.car
    pair.cdr = arg
    vm.push_arg pair
  end
end
