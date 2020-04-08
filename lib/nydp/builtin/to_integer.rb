module Nydp::Builtin
  class ToInteger
    include Nydp::Builtin::Base, Singleton

    def builtin_invoke_2 vm, arg
      arg = n2r arg

      i = if arg.respond_to? :to_i
            arg.to_i
          elsif arg.respond_to? :to_time
            arg.to_time.to_i
          else
            arg.to_s.to_i
          end

      vm.push_arg r2n i
    end

    def builtin_invoke vm, args
      builtin_invoke_2 vm, args.car
    end
  end
end
