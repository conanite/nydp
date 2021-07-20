class Nydp::Builtin::LessThan
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg(less_than(args.car, args.cdr) || Nydp::NIL)
    less_than(args.car, args.cdr) || Nydp::NIL
  end

  def less_than arg, args
    return arg if Nydp::NIL.is? args
    (arg < args.car) && less_than(args.car, args.cdr)
  end

  def call *args
    raise "hell"
  end

  def name ; "<" ; end
end
