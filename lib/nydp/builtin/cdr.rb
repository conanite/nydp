class Nydp::Builtin::Cdr
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg args.car.cdr
  end
end
