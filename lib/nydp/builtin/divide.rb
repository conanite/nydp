class Nydp::Builtin::Divide
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg divide(args.cdr, args.car)
  end

  def divide args, accum
    if Nydp::NIL.is? args
      accum
    else
      divide(args.cdr, (accum / args.car))
    end
  end

  def name ; "/" ; end
end
