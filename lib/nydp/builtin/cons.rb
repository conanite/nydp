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
      puts "arg #{arg} is pair? #{pair?(arg).inspect}"
      vm.push_arg (pair?(arg) ? arg : Nydp.NIL)
    end
  end
end
