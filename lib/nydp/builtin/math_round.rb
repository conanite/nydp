class Nydp::Builtin::MathRound
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg(args.car.round)
  end
end
