module Nydp::Builtin
  class ToString
    include Nydp::Builtin::Base

    def builtin_invoke vm, args
      arg = args.car
      val = case arg.class
            when Nydp::StringAtom
              arg
            else
              Nydp::StringAtom.new arg.to_s
            end
      vm.push_arg val
    end
  end

  class StringLength
    include Nydp::Builtin::Base

    def builtin_invoke vm, args
      arg = args.car
      val = case arg
            when Nydp::StringAtom
              arg.length
            else
              0
            end
      vm.push_arg val
    end
  end
end
