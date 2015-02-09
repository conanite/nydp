class Nydp::Builtin::TypeOf
  def initialize ns
    @ns = ns
  end

  def invoke vm, args
    arg = args.car
    type = Nydp::Symbol.mk(arg.nydp_type.to_sym, @ns) if arg.respond_to?(:nydp_type)
    vm.push_arg(type || Nydp.NIL)
  end
end
