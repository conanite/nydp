class Nydp::Builtin::Minus
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg diff(args.cdr, args.car)
  end

  def diff args, accum
    if Nydp.NIL.is? args
      accum
    else
      diff(args.cdr, (accum - args.car))
    end
  end

  def name ; "-" ; end
end
