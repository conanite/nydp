class Nydp::Builtin::Cdr
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg args.car.cdr
  end
end
