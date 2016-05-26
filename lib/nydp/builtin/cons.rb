module Nydp::Builtin
  class Cons
    include Nydp::Builtin::Base, Singleton

    def builtin_invoke vm, args
      vm.push_arg Nydp::Pair.new(args.car, args.cdr.car)
    end
  end
end
