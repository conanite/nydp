class Nydp::Builtin::Times
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg multiply(args, 1)
  end

  def multiply args, accum
    if Nydp.NIL.is? args
      accum
    else
      multiply(args.cdr, (accum * args.car))
    end
  end

  def name ; "*" ; end
end
