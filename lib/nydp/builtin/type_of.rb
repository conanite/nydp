class Nydp::Builtin::TypeOf
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    arg = args.car
    typename = if arg.respond_to?(:nydp_type)
                 arg.nydp_type.to_sym
               elsif arg.is_a? Numeric
                 :number
               else
                 "ruby/#{arg.class.name}".to_sym
               end

    type = Nydp::Symbol.mk(typename, vm.ns)

    vm.push_arg(type || Nydp::NIL)
  end
end
