class Nydp::Builtin::TypeOf
  def initialize ns
    @ns = ns
  end

  def invoke vm, args
    arg = args.car
    typename = if arg.respond_to?(:nydp_type)
                 arg.nydp_type.to_sym
               else
                 "ruby/#{arg.class.name}".to_sym
               end

    type = Nydp::Symbol.mk(typename, @ns)

    vm.push_arg(type || Nydp.NIL)
  end
end
