class Nydp::Builtin::Plus
  def invoke vm, args
    vm.push_arg sum(args, origin(args.car))
  end

  def sum args, accum
    if Nydp.NIL.is? args
      accum
    else
      sum(args.cdr, (accum + args.car))
    end
  end

  def origin obj
    case obj
    when Fixnum
      0
    when String, Nydp::StringAtom
      Nydp::StringAtom.new ""
    end
  end

  def to_s
    "Builtin:+"
  end
end
