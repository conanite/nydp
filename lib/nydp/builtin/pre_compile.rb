class Nydp::Builtin::PreCompile
  def invoke vm, args
    vm.push_arg args.car
  end
end
