class Nydp::Builtin::Times
  def invoke vm, args
    vm.push_arg multiply(args, 1)
  end

  def multiply args, accum
    if Nydp.NIL.is? args
      accum
    else
      multiply(args.cdr, (accum * args.car))
    end
  end
end
