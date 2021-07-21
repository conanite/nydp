class Nydp::Builtin::MathRound
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg(args.car.round)
    args.car.round
  end

  def builtin_call arg
    arg.round
  end
end
