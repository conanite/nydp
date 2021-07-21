class Nydp::Builtin::MathCeiling
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg(args.car.ceil)
    args.car.ceil
  end

  def builtin_call arg
    arg.ceil
  end
end
