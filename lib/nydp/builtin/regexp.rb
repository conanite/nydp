class Nydp::Builtin::Regexp
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg Regexp.compile(args.car.to_s)
    Regexp.compile(args.car.to_s)
  end
end
