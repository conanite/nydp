module Nydp::Builtin
  class Cons
    include Nydp::Builtin::Base

    def builtin_invoke vm, args
      vm.push_arg Nydp::Pair.new(args.car, args.cdr.car)
    end
  end

  class IsPair
    include Nydp::Helper, Nydp::Builtin::Base

    def builtin_invoke vm, args
      arg = args.car
      result = pair?(arg) ? Nydp.T : Nydp.NIL
      vm.push_arg result
    end
  end
end
