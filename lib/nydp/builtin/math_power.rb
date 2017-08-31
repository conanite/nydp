class Nydp::Builtin::MathPower
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg(args.car ** args.cdr.car)
  end
end
