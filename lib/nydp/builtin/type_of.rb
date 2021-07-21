class Nydp::Builtin::TypeOf
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke_1 vm, a0
    typename = if Nydp::NIL.is?(a0)
                 a0
               elsif a0.respond_to?(:nydp_type)
                 a0.nydp_type.to_sym
               elsif a0.is_a? Numeric
                 :number
               else
                 "ruby/#{a0.class.name}".to_sym
               end

    # type = Nydp::Symbol.mk(typename, vm.ns)
    type = typename

    (type || Nydp::NIL)
  end

  def builtin_invoke vm, args
    builtin_invoke_1 vm, args.car
  end

  def builtin_call *args
    builtin_invoke_1 nil, args.first
  end
end
