class Nydp::Builtin::TypeOf
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke_1 vm, a0
    typename = if a0.respond_to?(:nydp_type)
                 a0.nydp_type.to_sym
               elsif a0.is_a? Numeric
                 :number
               else
                 "ruby/#{a0.class.name}".to_sym
               end

    type = Nydp::Symbol.mk(typename, vm.ns)

    vm.push_arg(type || Nydp::NIL)
  end

  def builtin_invoke vm, args
    builtin_invoke_1 vm, args.car
  end
end
