class Nydp::Builtin::Car
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg args.car.car
  end
end
