class Nydp::Builtin::MathPower
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg(args.car ** args.cdr.car)
    args.car ** args.cdr.car
  end

  def builtin_call a0, a1
    a0 ** a1
  end
end
