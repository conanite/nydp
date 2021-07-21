class Nydp::Builtin::MathFloor
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg(args.car.floor)
    args.car.floor
  end

  def builtin_call arg
    arg.floor
  end
end
