class Nydp::Builtin::Puts
  def invoke vm, args
    s = args.map { |a| a.to_s }
    puts s.join ' '
    vm.push_arg args.car
  end
end
