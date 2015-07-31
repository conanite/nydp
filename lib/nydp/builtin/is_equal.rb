class Nydp::Builtin::IsEqual
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg ((args.car == args.cdr.car) ? Nydp.T : Nydp.NIL)
  end

  def name ; "eq?" ; end
end
