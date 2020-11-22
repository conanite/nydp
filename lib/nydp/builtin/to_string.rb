module Nydp::Builtin
  class ToString
    include Nydp::Builtin::Base, Singleton

    def builtin_invoke vm, args
      vm.push_arg args.car.to_s
    end
  end

  class StringLength
    include Nydp::Builtin::Base, Singleton

    def builtin_invoke vm, args
      arg = args.car
      val = case arg
            when String
              arg.length
            else
              0
            end
      vm.push_arg val
    end
  end
end
