class Nydp::Builtin::Inspect
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg args.car.inspect
  end
end
