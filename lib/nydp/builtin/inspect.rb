class Nydp::Builtin::Inspect
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg Nydp::StringAtom.new(args.car.inspect)
  end
end
