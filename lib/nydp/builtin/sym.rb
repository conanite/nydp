class Nydp::Builtin::Sym
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    args.car.to_s.to_sym
  end
end
