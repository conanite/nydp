class Nydp::Builtin::Car
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg args.car.car
  end
end
