module Nydp::Builtin
  class Cons
    def invoke vm, args
      vm.push_arg Nydp::Pair.new(args.car, args.cdr.car)
    end
  end
end
