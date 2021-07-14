class Nydp::Builtin::CdrSet
  include Nydp::Builtin::Base, Singleton

  # def builtin_invoke vm, args ; vm.push_arg(args.car.cdr = args.cdr.car) ; end
  def builtin_invoke vm, args ; args.car.cdr = args.cdr.car ; end
end
