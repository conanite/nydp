class Nydp::Builtin::Apply
  def invoke vm, args
    args.car.invoke vm, args.cdr.car
  end
end
