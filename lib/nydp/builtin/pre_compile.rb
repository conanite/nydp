class Nydp::Builtin::PreCompile
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg args.car
  end
end
