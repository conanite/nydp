class Nydp::Builtin::Sym
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    arg = args.car
    val = case arg.class
          when ::Symbol
            arg
          # when Nydp::Symbol
          #   arg
          else
            arg.to_s.to_sym
            # Nydp::Symbol.mk arg.to_s.to_sym, vm.ns
          end
    vm.push_arg val
  end
end
