class Nydp::Builtin::ToSym
  def initialize ns
    @ns = ns
  end
  def invoke vm, args
    arg = args.car
    val = case arg.class
          when Nydp::Symbol
            arg
          else
            Nydp::Symbol.mk arg.to_s.to_sym, @ns
          end
    vm.push_arg val
  end
end






