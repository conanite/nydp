class Nydp::Builtin::GreaterThan
  def invoke vm, args
    vm.push_arg (greater_than(args.car, args.cdr) ? Nydp.T : Nydp.NIL)
  end

  def greater_than arg, args
    return true if Nydp.NIL.is? args
    (arg > args.car) && greater_than(args.car, args.cdr)
  end
end
