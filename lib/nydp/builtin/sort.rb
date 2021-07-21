module Nydp
  class Builtin::Sort
    include Builtin::Base, Singleton

    def builtin_invoke vm, args
      args.car.to_a.sort._nydp_wrapper
    end

    def builtin_call arg
      arg.to_a.sort._nydp_wrapper
    end

    private

    def to_array pair, list
      pair.is_a?(Pair) ? to_array(pair.cdr, (list << pair.car)) : list
    end
  end
end
