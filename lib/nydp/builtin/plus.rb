class Nydp::Builtin::Plus
  def invoke vm, args
    vm.push_arg sum(args, 0)
  end

  def sum args, accum
    if Nydp::NIL.is? args
      accum
    else
      sum(args.cdr, (accum + args.car))
    end
  end
end
