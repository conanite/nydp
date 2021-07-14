class Nydp::Builtin::GreaterThan
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg(greater_than(args.car, args.cdr) || Nydp::NIL)
    greater_than(args.car, args.cdr) || Nydp::NIL
  end

  def greater_than arg, args
    return arg if Nydp::NIL.is? args
    (arg > args.car) && greater_than(args.car, args.cdr)
  end

  def name ; ">" ; end
end
