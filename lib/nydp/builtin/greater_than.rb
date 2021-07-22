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

  def builtin_call arg, *args
    while !args.empty?
      return nil unless args.first && arg > args.first
      arg = args.shift
    end
    return arg
  end
end
