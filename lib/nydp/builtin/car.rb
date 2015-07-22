class Nydp::Builtin::Car
  def invoke vm, args
    vm.push_arg args.car.car
  end

  def to_s; "car"; end
  def inspect; "builtin:car"; end
end
