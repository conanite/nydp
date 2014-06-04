module Nydp::Builtin
  class Cons
    def invoke vm, args
      vm.push_arg Nydp::Pair.new(args.car, args.cdr.car)
    end
  end

  class IsPair
    include Nydp::Helper
    def invoke vm, args
      arg = args.car
      result = pair?(arg) ? Nydp.T : Nydp.NIL
      vm.push_arg result
    end
  end
end
