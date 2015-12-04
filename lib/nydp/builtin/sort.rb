module Nydp
  class Builtin::Sort
    include Builtin::Base

    def builtin_invoke vm, args
      vm.push_arg Pair.from_list to_array(args.car, []).sort
    end

    private

    def to_array pair, list
      pair.is_a?(Pair) ? to_array(pair.cdr, (list << pair.car)) : list
    end
  end
end
