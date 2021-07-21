module Nydp::Builtin
  class ToString
    include Nydp::Builtin::Base, Singleton

    def builtin_invoke vm, args
      args.car.to_s
    end

    def builtin_call arg=nil
      arg.to_s
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
    end

    def builtin_call arg
      arg.to_s.length
    end
  end
end
