class Nydp::Builtin::LessThan
  def invoke vm, args
    vm.push_arg (less_than(args.car, args.cdr) ? Nydp.T : Nydp.NIL)
  end

  def less_than arg, args
    return true if Nydp.NIL.is? args
    (arg < args.car) && less_than(args.car, args.cdr)
  end
end