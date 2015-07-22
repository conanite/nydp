class Nydp::Builtin::Cdr
  def invoke vm, args
    vm.push_arg args.car.cdr
  end

  def to_s; "cdr"; end
  def inspect; "builtin:cdr"; end
end
