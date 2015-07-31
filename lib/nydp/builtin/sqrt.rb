class Nydp::Builtin::Sqrt
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg Math.sqrt args.car
  end
end
