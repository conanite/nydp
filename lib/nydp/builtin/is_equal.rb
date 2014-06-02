class Nydp::Builtin::IsEqual
  def invoke vm, args
    vm.push_arg (args.car == args.cdr.car) ? Nydp.T : Nydp.NIL)
  end
end
