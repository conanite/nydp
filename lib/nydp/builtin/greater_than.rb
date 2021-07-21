class Nydp::Builtin::GreaterThan
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    greater_than(args.car, args.cdr) || nil
  end

  def greater_than arg, args
    return arg if Nydp::NIL.is? args
    (arg > args.car) && greater_than(args.car, args.cdr)
  end

  def name ; ">" ; end

  def gt arg, args
    return arg if args.empty?
    a2 = args.shift
    (arg > a2) && gt(a2, args) # recursive, but we don't expect an argument list to be too long?
  end

  def builtin_call *args
    gt(args.shift, args) || nil
  end
end
