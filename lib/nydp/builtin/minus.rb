class Nydp::Builtin::Minus
  def invoke vm, args
    vm.push_arg diff(args.cdr, args.car)
  end

  def diff args, accum
    if Nydp.NIL.is? args
      accum
    else
      diff(args.cdr, (accum - args.car))
    end
  end
end
