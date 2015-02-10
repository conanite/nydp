class Nydp::Builtin::Inspect
  def invoke vm, args
    vm.push_arg Nydp::StringAtom.new(args.car.inspect)
  end
end
