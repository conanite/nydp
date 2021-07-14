class Nydp::Builtin::PreCompile
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg args.car
    args.car
  end
end
